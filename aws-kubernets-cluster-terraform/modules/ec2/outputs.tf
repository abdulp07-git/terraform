output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.k8s_node.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.k8s_node.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.k8s_node.private_ip
}

output "instance_name" {
  description = "Name of the instance"
  value       = var.instance_name
}

output "node_type" {
  description = "Type of Kubernetes node"
  value       = var.node_type
}
