terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "alb" {
  source = "../../modules/networking/alb"

  alb_name = var.alb_name
  subnet_ids = data.aws_subnets.default.ids
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}