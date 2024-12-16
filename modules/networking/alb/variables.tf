variable "alb_name" {
  description = "The name to use fot this ALB"
  type = string
}

variable "subnet_ids" {
  description = "Subnet ids"
  type = list(string)
}