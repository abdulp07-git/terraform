terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Network Module
module "network" {
  source = "./modules/network"

  vpc_cidr    = var.vpc_cidr
  subnets     = var.subnets
  environment = var.environment
  project     = var.project
}

# Control Plane EC2 Instance
module "control_plane" {
  source = "./modules/ec2"

  instance_name     = "k8s-control-plane"
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_ids["public-1"]
  security_group_id = module.network.sg_control_plane_id
  key_name          = var.ssh_key_name
  node_type         = "controlPlane"
  environment       = var.environment
  project           = var.project
}

# Worker Node EC2 Instance
module "worker_node" {
  source = "./modules/ec2"

  instance_name     = "k8s-worker-node"
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_ids["public-2"]
  security_group_id = module.network.sg_data_plane_id
  key_name          = var.ssh_key_name
  node_type         = "dataPlane"
  environment       = var.environment
  project           = var.project
}
