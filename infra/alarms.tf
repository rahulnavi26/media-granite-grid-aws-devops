# infra/alarms.tf - log groups and alarms
# The 5xx alarm is wired into the ASG instance refresh (auto rollback) in asg.tf.

resource "aws_cloudwatch_log_group" "svc" {
  for_each = var.services

  name              = "/media/${var.env}/${each.key}"
  retention_in_days = var.env == "prod" ? 90 : 14
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  for_each = var.services

  alarm_name          = "media-${var.env}-${each.key}-5xx"
  alarm_description   = "Target 5xx responses from ${each.key}; triggers instance refresh rollback"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.public.arn_suffix
    TargetGroup  = aws_lb_target_group.svc[each.key].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  for_each = var.services

  alarm_name          = "media-${var.env}-${each.key}-unhealthy-hosts"
  alarm_description   = "At least one ${each.key} target is failing health checks"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.public.arn_suffix
    TargetGroup  = aws_lb_target_group.svc[each.key].arn_suffix
  }
}
