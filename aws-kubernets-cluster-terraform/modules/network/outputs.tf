output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "subnet_cidrs" {
  description = "Map of subnet names to CIDR blocks"
  value       = { for k, v in aws_subnet.public : k => v.cidr_block }
}

output "sg_control_plane_id" {
  description = "Control plane security group ID"
  value       = aws_security_group.control_plane.id
}

output "sg_data_plane_id" {
  description = "Data plane security group ID"
  value       = aws_security_group.data_plane.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}
