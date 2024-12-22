    variable "db_username" {
    description = "The userame for the database"
    type = string
    sensitive = true
    default = null
}

variable "db_password" {
  description = "The password for the database"
  type = string
  sensitive = true
  default = null
}

variable "db_identifier_prefix" {
  description = "identifier prefix"
  type = string
  default = "example"
}

variable "db_name" {
  default = null
  type = string
}

variable "backup_retention_period" {
  description = "Dats ti retaub backups. Myst be > 0 to enable replication."
  type = number
  default = null
}

variable "replicate_source_db" {
  description = "If specified, replicate the RDS database at the given ARN"
  type = string
  default = null
}