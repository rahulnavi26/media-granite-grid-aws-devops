# infra/variables.tf

variable "env" {
  description = "Environment name: dev, staging or prod"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "image_tag" {
  description = "Immutable image tag for this release (set by the pipeline)"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry host in the tools account (set by the pipeline)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for this environment's VPC"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to spread across (2 or 3)"
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway (cheaper, for non-prod) instead of one per AZ"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN. Empty = HTTP only (demo); set it to serve HTTPS and redirect HTTP."
  type        = string
  default     = ""
}

variable "services" {
  description = "One entry per service: sizing, port and ALB routing"
  type = map(object({
    instance_type = string
    port          = number
    min           = number
    max           = number
    path          = string # ALB path pattern, e.g. /publishing/*
    health_path   = string # target group health check
    priority      = number # ALB listener rule priority (unique)
  }))
}

variable "create_ecr" {
  description = "Create the ECR repositories (set true only when applying in the shared tools account)"
  type        = bool
  default     = false
}

variable "ecr_pull_account_ids" {
  description = "AWS account IDs allowed to pull images (dev, staging, prod). Used when create_ecr = true."
  type        = list(string)
  default     = []
}
