variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}
