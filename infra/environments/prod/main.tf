
module "django" {
  source      = "../../modules/django"
  gcp_region  = "europe-west1"
  gcp_project = "helical-gist-453315-a2"
}
