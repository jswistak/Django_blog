variable "gcp_region" {
  description = "Google Cloud Region"
  default     = "europe-west1"
  type        = string

}
variable "gcp_project" {
  description = "Google Cloud Project ID"
  type        = string

}

locals {
  service_env_variables = [
    { name = "DB_NAME", type = "text", value = google_sql_database.django_db.name },
    { name = "DB_USER", type = "text", value = google_sql_user.django_user.name },
    { name = "DB_PASSWORD", type = "text", value = google_secret_manager_secret_version.db_password.secret_data },
    { name = "DB_HOST", type = "text", value = "/cloudsql/${var.gcp_project}:${var.gcp_region}:${google_sql_database_instance.default.name}" },

    # static and media buckets
    { name = "GS_STATIC_BUCKET_NAME", type = "text", value = google_storage_bucket.static_files.name },
    { name = "GS_MEDIA_BUCKET_NAME", type = "text", value = google_storage_bucket.media_files.name },


  ]

}
