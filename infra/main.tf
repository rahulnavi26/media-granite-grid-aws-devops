# infra/main.tf - provider, backend and shared data sources

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Bucket, key, region and lock table are supplied by the pipeline
  # via -backend-config (see templates/deploy-env.yml).
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "media-granite-grid"
      Env       = var.env
      ManagedBy = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Amazon Linux 2023 AMI, resolved at plan time
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  # ECR lives in the shared tools account; its ID is the first part of the registry host
  ecr_account_id = split(".", var.ecr_registry)[0]
}
