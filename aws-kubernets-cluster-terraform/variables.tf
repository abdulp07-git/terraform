variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "public-1" = {
      cidr = "10.0.0.0/20"
      az   = "ap-south-1a"
    }
    "public-2" = {
      cidr = "10.0.16.0/20"
      az   = "ap-south-1b"
    }
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "my_server_01"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "k8s-cluster"
}
