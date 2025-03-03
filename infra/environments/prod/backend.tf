# terraform {
#   backend "gcs" {
#     bucket = "terraform-state-bucket"
#     prefix = "prod/backend"

#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
