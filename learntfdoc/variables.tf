variable "region" {
  type    = string
  default = "ap-south-1"
}

locals {
  env = "default-vpc"
}

variable "network" {
  description = "network variables"
  default = {
    default-vpc = {
      vpc-cidr = "10.0.0.0/16",
      subnets = {
        pub1 = {
          pub1-cidr = "10.0.0.0/20"
        }
        pub2 = {
          pub1-cidr = "10.0.16.0/20"
        }
      }
    }
  }
}
