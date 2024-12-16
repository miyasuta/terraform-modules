locals {
  http_port = 80
  any_port = 0
  any_protocol = -1
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_launch_template" "example" {
  name          = var.cluster_name
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    security_groups             = [aws_security_group.instance.id]
    associate_public_ip_address = true
  }

  user_data = var.user_data

  # Autoscaling Groupがある起動設定を使った場合に必須
  lifecycle {
    create_before_destroy = true
    precondition {
      condition = data.aws_ec2_instance_type.instance.free_tier_eligible
      error_message = "${var.instance_type} is not part of the AWS Free Tier!"
    }
  }
}

data "aws_ec2_instance_type" "instance" {
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "example" {
  name = "${var.cluster_name}-${aws_launch_template.example.name}"

  launch_template {
    id      = aws_launch_template.example.id
    version = aws_launch_template.example.latest_version
  }
  vpc_zone_identifier = var.subnet_ids

  # ロードバランサとの組み合わせを設定
  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # ASGデプロイが完了すると判断する前に、最低でもこの数の
  # インスタンスがヘルスチェックをパスするのを待つ
  min_elb_capacity = var.min_size

  # このASGを置き換えるとき、置き換え先を先に作成してから元のASGを削除
  lifecycle {
    create_before_destroy = true
    postcondition {
      condition = length(self.availability_zones) > 1
      error_message = "You must use more than one AZ for high availability!"
    }
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "instance" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# autoscaling
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1: 0

  scheduled_action_name = "${var.cluster_name}-scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1: 0

  scheduled_action_name = "${var.cluster_name}-scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.example.name
}