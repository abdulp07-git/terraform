variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to instance"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "node_type" {
  description = "Type of Kubernetes node (controlPlane or dataPlane)"
  type        = string
  validation {
    condition     = contains(["controlPlane", "dataPlane"], var.node_type)
    error_message = "node_type must be either 'controlPlane' or 'dataPlane'"
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}
