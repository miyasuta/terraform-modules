variable "environment" {
  description = "THe name of the environment we're deploying to "
  type = string
}

# variable "cluster_name" {
#   description = "The name to use for all the cluster resources"
#   type = string
# }

variable "ami" {
  description = "The AMI to run in the cluster"
  type = string
  default = "ami-0fb653ca2d3203ac1"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type = string
  default = "t2.micro"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "server_text" {
  description = "The text the web server should return"
  type = string
  default = "Hello, World"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
  type = number
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type = map(string)
  default = {}
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
  default = null
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
  default = null
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy into"
  type = string
  default = null
}

variable "subnet_ids" {
  description = "The IDs of the subnets to deploy into"
  type = list(string)
  default = null
}

variable "mysql_config" {
  description = "The config for the MySQL DB"
  type = object({
    address = string
    port = number
  })
  default = null
}