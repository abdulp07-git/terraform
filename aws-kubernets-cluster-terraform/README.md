# Kubernetes Cluster on AWS - Terraform Infrastructure

This Terraform project creates the infrastructure for a temporary development Kubernetes cluster on AWS with 2 EC2 instances (1 control plane + 1 worker node).

## Directory Structure

```
terraform/
├── main.tf                 # Root module
├── variables.tf            # Root variables
├── outputs.tf              # Root outputs
├── terraform.tfvars        # Variable values
├── modules/
│   ├── network/
│   │   ├── vpc.tf
│   │   ├── igw.tf
│   │   ├── subnets.tf
│   │   ├── route_table.tf
│   │   ├── security_groups.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **SSH Key Pair** `key-01edb3b688d072325` must exist in ap-south-1 region
4. Appropriate AWS IAM permissions to create VPC, EC2, Security Groups, etc.

## What Gets Created

### Network Module
- **VPC**: 10.0.0.0/16 CIDR block
- **Internet Gateway**: For public internet access
- **Subnets**: 2 public subnets with /20 CIDR blocks
  - public-1: 10.0.0.0/20 in ap-south-1a
  - public-2: 10.0.16.0/20 in ap-south-1b
- **Route Table**: Routes traffic to internet via IGW
- **Security Groups**:
  - Control Plane SG: Ports 22, 6443, 2379-2380, 10250, 10257, 10259
  - Worker Node SG: Ports 22, 80, 443, 10250, 30000-32767

### EC2 Module
- **2 EC2 Instances**: t3.medium with Ubuntu 22.04 LTS
  - Control Plane: k8s-control-plane (in public-1 subnet)
  - Worker Node: k8s-worker-node (in public-2 subnet)
- **30GB Root Volume** (gp3) for each instance
- **Public IPs** enabled for SSH access
- **SSH Key**: Uses existing key-01edb3b688d072325

## Usage

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Review and Customize Variables

Edit `terraform.tfvars` if needed. Default values are:
- Region: ap-south-1
- Instance Type: t3.medium
- VPC CIDR: 10.0.0.0/16
- Subnets: 10.0.0.0/20, 10.0.16.0/20

### 3. Plan the Infrastructure

```bash
terraform plan
```

### 4. Create the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

### 5. Get Outputs

After successful creation, Terraform will output:
- Control plane public IP
- Worker node public IP
- Control plane private IP
- Worker node private IP
- VPC ID
- Subnet IDs

You can also retrieve outputs anytime:

```bash
terraform output
```

### 6. SSH to Instances

```bash
# Control Plane
ssh -i /path/to/your/key.pem ubuntu@<control_plane_public_ip>

# Worker Node
ssh -i /path/to/your/key.pem ubuntu@<worker_node_public_ip>
```

### 7. Destroy the Infrastructure

When done with the cluster:

```bash
terraform destroy
```

Type `yes` when prompted.

## Adding More Subnets

To add more subnets, edit the `subnets` variable in `terraform.tfvars`:

```hcl
subnets = {
  "public-1" = {
    cidr = "10.0.0.0/20"
    az   = "ap-south-1a"
  }
  "public-2" = {
    cidr = "10.0.16.0/20"
    az   = "ap-south-1b"
  }
  "public-3" = {
    cidr = "10.0.32.0/20"
    az   = "ap-south-1c"
  }
}
```

Then run `terraform apply` to update the infrastructure.

## Subnet Naming Convention

Subnets use a map structure, so you can reference them by name:
- `module.network.subnet_ids["public-1"]` - Returns subnet ID of public-1
- `module.network.subnet_ids["public-2"]` - Returns subnet ID of public-2

This makes it easy to add/remove/reference subnets without using array indexes.

## Security Notes

1. **SSH Access**: Currently open to 0.0.0.0/0. For production, restrict to specific IPs in security groups.
2. **Key Management**: Ensure your SSH private key is stored securely.
3. **Temporary Use**: This setup is for development only. Do not use in production.

## Next Steps - Phase 2

After infrastructure is ready:
1. Use Ansible to install Kubernetes components
2. Configure control plane with kubeadm
3. Join worker nodes to the cluster
4. Install CNI plugin (Calico/Flannel)
5. Install nginx ingress controller

## Troubleshooting

### SSH Key Not Found
Ensure the key pair `key-01edb3b688d072325` exists in ap-south-1:
```bash
aws ec2 describe-key-pairs --region ap-south-1 --key-name key-01edb3b688d072325
```

### Terraform State
State file `terraform.tfstate` tracks your infrastructure. Keep it safe and never commit to version control.

### Instance Not Accessible
Check security group rules and ensure your public IP hasn't changed.

## Tags

All resources are tagged with:
- **Name**: Resource-specific name
- **Environment**: dev
- **Project**: k8s-cluster
- **ManagedBy**: Terraform
- **NodeType**: controlPlane or DataPlane (for EC2 instances)
