provider "aws" {
    region = "us-east-2"
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "hello_world_app" {
  source = "../../../modules/services/hello-world-app"

  server_text = "Hello, World"
  environment = var.environment

  mysql_config = var.mysql_config
  min_size = 2
  max_size = 2
  enable_autoscaling = false
  ami = data.aws_ami.ubuntu.id
}

output "alb_dns_name" {
  value = module.hello_world_app.alb_dns_name
}

# module "mysql" {
#   source = "../../../modules/data-stores/mysql"

#   db_name = var.db_name
#   db_username = var.db_username
#   db_password = var.db_password
# }