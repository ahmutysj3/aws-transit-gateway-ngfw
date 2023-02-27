terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
  }

  backend "s3" {
    bucket = "trace-tf-unlocked-bucket"
    key    = "main/transit-gateway/terraform.tfstate"
    region = "us-east-1"
    #dynamodb_table = "terraform_state"
  }
}

provider "aws" {
  region = var.region_aws
}