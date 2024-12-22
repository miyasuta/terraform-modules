variable "db_username" {
    description = "The userame for the database"
    type = string
    sensitive = true
    default = "dbadmin"
}

variable "db_password" {
  description = "The password for the database"
  type = string
  sensitive = true
  default = "initpass01"
}

variable "db_name" {
  default = "example"
  type = string
}

variable "mysql_config" {
  description = "The config for the MySQL DB"
  type = object({
    address = string
    port = number
  })

  default = {
    address = "mock-mysql-address"
    port = 12345
  }
}

variable "environment" {
  description = "The bae of the environment we're deploying to"
  type = string
  default = "example"
}