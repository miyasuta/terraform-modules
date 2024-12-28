provider "aws" {
  region = "us-east-2"
}

# terraform {
#   backend "s3" {
#     key = "stage/services/webserver-cluster/terraform.tfstate"

#     bucket = "miyasuta-terraform-up-and-running-state"
#     region = "us-east-2"
#     dynamodb_table = "terraform-up-and-running-locks"
#     encrypt = true
#   }
# }

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "webserver_cluster" {
    source = "../../../../modules/services/hello-world-app"

    server_text = "Hello, World"
    environment = var.environment
    db_remote_state_bucket = var.db_remote_state_bucket
    db_remote_state_key = var.db_remote_state_key

    instance_type = "t2.micro"
    min_size = 2
    max_size = 4
    enable_autoscaling = false
    ami = data.aws_ami.ubuntu.id
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type = "ingress"
  security_group_id = module.webserver_cluster.instance_security_group_id

  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}