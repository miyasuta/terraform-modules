provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    key = "stage/data-stores/mysql/terraform.tfstate"

    bucket = "miyasuta-terraform-up-and-running-state"
    region = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

module "mysql" {
  source = "../../../modules/data-stores/mysql"

  db_identifier_prefix = "terraform-up-and-running-stage"
  db_name = "example_database"
  db_username = var.db_username
  db_password = var.db_password
}

output "address" {
    value = module.mysql.address
    description = "Connect to the database at this endpoint"
}

output "port" {
    value = module.mysql.port
    description = "The port the database is listening on"
}