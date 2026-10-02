# infra/iam.tf - least-privilege instance roles (one per service)
# Each role can: pull from ECR, write its own log group, read its own secret. Nothing else.

# Secret containers only. Values are set outside Terraform so they never enter state.
resource "aws_secretsmanager_secret" "svc" {
  for_each = var.services

  name                    = "media/${var.env}/${each.key}"
  recovery_window_in_days = var.env == "prod" ? 30 : 0
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "svc" {
  for_each = var.services

  name               = "media-${var.env}-${each.key}-instance"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

data "aws_iam_policy_document" "svc" {
  for_each = var.services

  statement {
    sid       = "EcrAuthToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPullMediaRepos"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["arn:aws:ecr:${var.region}:${local.ecr_account_id}:repository/media/*"]
  }

  statement {
    sid       = "WriteOwnLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.svc[each.key].arn}:*"]
  }

  statement {
    sid       = "ReadOwnSecret"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.svc[each.key].arn]
  }
}

resource "aws_iam_role_policy" "svc" {
  for_each = var.services

  name   = "media-${var.env}-${each.key}"
  role   = aws_iam_role.svc[each.key].id
  policy = data.aws_iam_policy_document.svc[each.key].json
}

# Session Manager access instead of SSH keys
resource "aws_iam_role_policy_attachment" "ssm" {
  for_each = var.services

  role       = aws_iam_role.svc[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "svc" {
  for_each = var.services

  name = "media-${var.env}-${each.key}"
  role = aws_iam_role.svc[each.key].name
}
