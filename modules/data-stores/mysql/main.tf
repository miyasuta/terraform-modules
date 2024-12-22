terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix = var.db_identifier_prefix
  allocated_storage = 10
  instance_class = "db.t3.micro"
  skip_final_snapshot = true

  # バックアップを有効化
  backup_retention_period = var.backup_retention_period

  # 設定されているときはこのデータベースはレプリカ
  replicate_source_db = var.replicate_source_db

  # replicate_source_dbが設定されていないときだけこれらのパラメータを設定
  engine = var.replicate_source_db == null ? "mysql" : null
  db_name = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null
}