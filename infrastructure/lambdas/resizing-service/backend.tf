terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }

  backend "s3" {
    bucket         = "tf-state-aws-ugf-2024"
    key            = "infrastructure/resizing-service/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "tf-lock-aws-ugf-2024"
    encrypt        = true
  }
}

provider "aws" {
  region = var.default_aws_region
}