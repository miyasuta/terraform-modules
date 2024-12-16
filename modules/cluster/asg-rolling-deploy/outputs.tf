output "alb_dns_name" {
  value = aws_autoscaling_group.example.name
  description = "THe name of hte Auto Scaling Group"
}
output "instance_security_group_id" {
  value = aws_security_group.instance.id
  description = "The ID of the EC2 Instance Security Group"
}

output "asg_name" {
  value = aws_security_group.instance.name
  description = "The name of the EC2 Instance Security Group"
}