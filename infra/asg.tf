# infra/asg.tf - one launch template + ASG per service
# A new image tag => new launch template version => immutable instance refresh

resource "aws_launch_template" "svc" {
  for_each      = var.services
  name_prefix   = "media-${var.env}-${each.key}-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = each.value.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.svc[each.key].name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    region    = var.region
    image     = "${var.ecr_registry}/media/${each.key}:${var.image_tag}"
    image_tag = var.image_tag
    port      = each.value.port
    log_group = aws_cloudwatch_log_group.svc[each.key].name
    secret_id = "media/${var.env}/${each.key}"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Service  = each.key
      Env      = var.env
      ImageTag = var.image_tag
    }
  }
}

resource "aws_autoscaling_group" "svc" {
  for_each            = var.services
  name                = "media-${var.env}-${each.key}"
  min_size            = each.value.min
  max_size            = each.value.max
  desired_capacity    = each.value.min
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.svc[each.key].arn]

  health_check_type         = "ELB"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.svc[each.key].id
    version = aws_launch_template.svc[each.key].latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100 # never drop below current capacity
      max_healthy_percentage = 200 # launch new before terminating old
      instance_warmup        = 90
      auto_rollback          = true
      alarm_specification {
        alarms = [aws_cloudwatch_metric_alarm.target_5xx[each.key].alarm_name]
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity] # owned by scaling policies
  }
}

output "alb_dns_name" {
  value = aws_lb.public.dns_name
}

output "asg_names" {
  value = { for k, g in aws_autoscaling_group.svc : k => g.name }
}
