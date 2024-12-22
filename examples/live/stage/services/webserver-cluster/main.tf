provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    key = "stage/services/webserver-cluster/terraform.tfstate"

    bucket = "miyasuta-terraform-up-and-running-state"
    region = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"

    ami = "ami-0fb653ca2d3203ac1"
    server_text = "New server text 4"

    cluster_name = "webservers-stage"
    db_remote_state_bucket = "miyasuta-terraform-up-and-running-state"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

    instance_type = "t2.micro"
    min_size = 2
    max_size = 4
    enable_autoscaling = false
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}