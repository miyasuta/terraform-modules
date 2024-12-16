variable "environment" {
  description = "THe name of the environment we're deploying to "
  type = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "ami" {
  description = "The AMI to run in the cluster"
  type = string
  default = "ami-0fb653ca2d3203ac1"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type = string
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