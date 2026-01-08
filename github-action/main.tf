
terraform {
  required_version = "1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }

  backend "s3" {
    bucket         = "abd-tfstate"
    key            = "github-action/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source         = "./modules/network"
  vpc-cidr-block = var.network[local.env]["vpc-cidr"]
  vpc-name       = local.env
  subnets        = var.network[local.env]["subnets"]
}
