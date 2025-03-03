

###########################################
# Database for the django app
###########################################

# Database password for the django user
resource "random_password" "database_password" {
  length  = 32
  special = false
}

resource "google_sql_database_instance" "default" {
  name             = "django-sql"
  database_version = "MYSQL_8_0"
  region           = var.gcp_region
  project          = var.gcp_project

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database" "django_db" {
  name     = "django_db"
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "django_user" {
  name     = "django_user"
  instance = google_sql_database_instance.default.name
  password = random_password.database_password
}

##############################
# Service Account for Cloud Run
##############################
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-django"
  display_name = "Cloud Run Service Account for Django"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.gcp_project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
resource "google_cloud_run_v2_service" "service" {
  name     = "django-service"
  location = var.gcp_region


  template {
    service_account = google_service_account.cloud_run_sa.email
    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }

    timeout = "120s"

    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project}/djangoapp/app:latest"
      ports {
        container_port = 8000
      }
      dynamic "env" {
        for_each = local.service_env_variables
        content {
          name = env.value.name

          value = env.value.type == "text" ? env.value.value : null

          dynamic "value_source" {
            for_each = env.value.type == "secret" ? [1] : []
            content {
              secret_key_ref {
                secret  = env.value.secret_ref
                version = "latest"
              }
            }
          }
        }
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "1024Mi"
        }

      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.default.connection_name]
      }
    }
    # vpc_access {
    #   connector = google_vpc_access_connector.vpc_connector.id
    # }
  }
}

# ###########################################
# # Redis for the django app
# ###########################################

# resource "google_redis_instance" "redis" {
#   name               = "redis-django"
#   tier               = "BASIC"
#   memory_size_gb     = 1
#   region             = var.gcp_region
#   authorized_network = google_compute_network.redis.id

#   redis_configs = {
#     maxmemory-policy = "allkeys-lru"
#   }
# }

# ###########################################
# Networking
# ###########################################

# resource "google_compute_network" "redis" {
#   name = "redis-vpc"
# }

# resource "google_vpc_access_connector" "vpc_connector" {
#   name          = "vpc-django-connector"
#   region        = var.gcp_region
#   network       = google_compute_network.redis.name
#   ip_cidr_range = "10.8.0.0/28"
# }

# ###########################################
# Cloud run public 
# ###########################################


resource "google_cloud_run_service_iam_binding" "django_public" {
  location = google_cloud_run_v2_service.service.location
  service  = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

# ###########################################
# # File storage for the django app
# ###########################################


resource "google_storage_bucket" "static_files" {
  name          = "django-static"
  location      = var.gcp_region
  force_destroy = false
}

resource "google_storage_bucket" "media_files" {
  name          = "django-media"
  location      = var.gcp_region
  force_destroy = false
}


# ###########################################
# Artifact Registry
# ###########################################

resource "google_artifact_registry_repository" "django_containers" {
  location               = var.gcp_region
  repository_id          = "containers_django"
  description            = "Django app containers"
  format                 = "DOCKER"
  cleanup_policy_dry_run = false

  docker_config {
    immutable_tags = false
  }
  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["*"]
      older_than   = "30d"
    }
  }
}
# ###########################################
# Cloud run job for django commands such as migrate and collectstatic
# ###########################################


resource "google_cloud_run_v2_job" "run_django_commands" {
  provider = google-beta
  name     = "run-django-commands"
  location = var.gcp_region
  depends_on = [
    google_secret_manager_secret.db_password,
    google_cloud_run_v2_service.service,
  ]
  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].labels,
      template[0].template[0].containers[0].name
    ]
  }

  launch_stage = "GA"
  template {

    template {
      service_account = google_service_account.cloud_run_sa.email

      containers {
        image   = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project}/djangoapp/app:latest"
        command = ["python", "manage.py"]

        ports {
          container_port = 8000
        }
        dynamic "env" {
          for_each = local.service_env_variables
          content {
            name = env.value.name

            value = env.value.type == "text" ? env.value.value : null

            dynamic "value_source" {
              for_each = env.value.type == "secret" ? [1] : []
              content {
                secret_key_ref {
                  secret  = env.value.secret_ref
                  version = "latest"
                }
              }
            }
          }
        }



        resources {
          limits = {
            cpu    = "2"
            memory = "4Gi"
          }
        }
        volume_mounts {
          mount_path = "/job_output"
          name       = "job_volume"
        }
      }
    }
  }
}


# ###########################################
# Secret manager for the django app
# ###########################################

resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.database_password.result
}
