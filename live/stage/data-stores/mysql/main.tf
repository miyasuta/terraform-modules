provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
  }
}

module "mysql" {
  source = "../../../../modules/data-stores/mysql"

  db_name = var.db_name
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