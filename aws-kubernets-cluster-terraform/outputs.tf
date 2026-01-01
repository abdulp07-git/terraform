output "control_plane_public_ip" {
  description = "Public IP of control plane instance"
  value       = module.control_plane.public_ip
}

output "worker_node_public_ip" {
  description = "Public IP of worker node instance"
  value       = module.worker_node.public_ip
}

output "control_plane_private_ip" {
  description = "Private IP of control plane instance"
  value       = module.control_plane.private_ip
}

output "worker_node_private_ip" {
  description = "Private IP of worker node instance"
  value       = module.worker_node.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = module.network.subnet_ids
}
