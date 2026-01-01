# Security Group for Control Plane
resource "aws_security_group" "control_plane" {
  name        = "${var.project}-sg-control-plane"
  description = "Security group for Kubernetes control plane"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project}-sg-control-plane"
    Environment = var.environment
    Project     = var.project
    NodeType    = "ControlPlane"
    ManagedBy   = "Terraform"
  }
}

# Control Plane Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "cp_ssh" {
  security_group_id = aws_security_group.control_plane.id
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "cp_api_server" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Kubernetes API server"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "cp_etcd" {
  security_group_id = aws_security_group.control_plane.id
  description       = "etcd server client API"
  from_port         = 2379
  to_port           = 2380
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "cp_kubelet" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Kubelet API"
  from_port         = 10250
  to_port           = 10250
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "cp_scheduler" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kube-scheduler"
  from_port         = 10259
  to_port           = 10259
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "cp_controller_manager" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kube-controller-manager"
  from_port         = 10257
  to_port           = 10257
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

# Control Plane Egress Rule
resource "aws_vpc_security_group_egress_rule" "cp_all_traffic" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Security Group for Worker Nodes
resource "aws_security_group" "data_plane" {
  name        = "${var.project}-sg-data-plane"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project}-sg-data-plane"
    Environment = var.environment
    Project     = var.project
    NodeType    = "DataPlane"
    ManagedBy   = "Terraform"
  }
}

# Worker Node Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "wn_ssh" {
  security_group_id = aws_security_group.data_plane.id
  description       = "SSH from control plane"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "wn_kubelet" {
  security_group_id = aws_security_group.data_plane.id
  description       = "Kubelet API from control plane"
  from_port         = 10250
  to_port           = 10250
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "wn_nodeport" {
  security_group_id = aws_security_group.data_plane.id
  description       = "NodePort Services"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "wn_http" {
  security_group_id = aws_security_group.data_plane.id
  description       = "HTTP traffic for nginx ingress"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "wn_https" {
  security_group_id = aws_security_group.data_plane.id
  description       = "HTTPS traffic for nginx ingress"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Worker Node Egress Rule
resource "aws_vpc_security_group_egress_rule" "wn_all_traffic" {
  security_group_id = aws_security_group.data_plane.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
