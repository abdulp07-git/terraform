# Kubernetes Cluster Setup with Ansible

This Ansible project automates the complete setup of a Kubernetes cluster with:
- **Kubernetes Version**: 1.28
- **Container Runtime**: containerd 1.7.2
- **CNI Plugin**: Calico 3.26.1
- **Pod Network**: 192.168.0.0/16

## Directory Structure

```
ansible/
├── ansible.cfg           # Ansible configuration
├── hosts.ini            # Inventory file with IPs
├── site.yml             # Main playbook (runs all)
├── common.yml           # Common setup for all nodes
├── control-plane.yml    # Control plane initialization
├── worker-nodes.yml     # Worker node join
└── README.md           # This file
```

## Prerequisites

1. **Ansible installed** on your local machine:
   ```bash
   sudo apt update
   sudo apt install ansible -y
   ```

2. **SSH access** to all nodes with the private key
3. **Terraform outputs** with actual IPs from Phase 1
4. **Update hosts.ini** with real IPs from Terraform

## Configuration

### Step 1: Update Inventory File

Replace the placeholder IPs in `hosts.ini` with actual IPs from Terraform output:

```bash
# Get IPs from Terraform
cd ../terraform
terraform output

# Update hosts.ini with real IPs
cd ../ansible
vim hosts.ini
```

Example with real IPs:
```ini
[control_plane]
k8s-control-plane ansible_host=13.232.45.67

[worker_nodes]
k8s-worker-node-1 ansible_host=13.232.45.68
k8s-worker-node-2 ansible_host=13.232.45.69  # If you have more nodes
```

### Step 2: Test Connectivity

```bash
ansible all -m ping
```

Expected output:
```
k8s-control-plane | SUCCESS => {...}
k8s-worker-node-1 | SUCCESS => {...}
```

## Usage

### Option 1: Run Complete Setup (Recommended)

Run everything in one go:

```bash
ansible-playbook site.yml
```

This will:
1. Install containerd and Kubernetes packages on all nodes
2. Initialize control plane with Calico CNI
3. Join worker nodes to the cluster

**Estimated time**: 10-15 minutes

### Option 2: Run Step-by-Step

If you prefer to run playbooks separately:

```bash
# Step 1: Common setup on all nodes
ansible-playbook common.yml

# Step 2: Initialize control plane
ansible-playbook control-plane.yml

# Step 3: Join worker nodes
ansible-playbook worker-nodes.yml
```

## What Each Playbook Does

### common.yml
- Updates system packages
- Disables swap (required for Kubernetes)
- Loads kernel modules (overlay, br_netfilter)
- Configures sysctl parameters
- Installs containerd runtime
- Installs runc and CNI plugins
- Installs kubeadm, kubelet, kubectl

### control-plane.yml
- Initializes Kubernetes cluster with kubeadm
- Sets up kubectl config for ubuntu user
- Installs Calico CNI plugin
- Generates join command for worker nodes
- Saves join command to `join-command.sh`

### worker-nodes.yml
- Copies join command to worker nodes
- Joins nodes to the cluster
- Verifies node is part of cluster

## Post-Installation

### Verify Cluster Status

SSH to control plane:
```bash
ssh -i /home/user/Downloads/my_server_01.pem ubuntu@<CONTROL_PLANE_IP>
```

Check nodes:
```bash
kubectl get nodes
```

Expected output:
```
NAME                STATUS   ROLES           AGE   VERSION
k8s-control-plane   Ready    control-plane   5m    v1.28.0
k8s-worker-node-1   Ready    <none>          3m    v1.28.0
```

Check pods:
```bash
kubectl get pods -A
```

Check Calico status:
```bash
kubectl get pods -n kube-system -l k8s-app=calico-node
```

### Access Cluster from Local Machine

Copy kubeconfig from control plane to your local machine:

```bash
# On your local machine
scp -i /home/user/Downloads/my_server_01.pem \
  ubuntu@<CONTROL_PLANE_IP>:/home/ubuntu/.kube/config \
  ~/.kube/config-k8s-dev

# Use the config
export KUBECONFIG=~/.kube/config-k8s-dev
kubectl get nodes
```

## Testing the Cluster

### Deploy a Test Application

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Expose it as NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# Get the NodePort
kubectl get svc nginx

# Access from browser
curl http://<WORKER_NODE_IP>:<NODE_PORT>
```

## Troubleshooting

### Nodes Not Ready

Check kubelet status:
```bash
sudo systemctl status kubelet
```

Check kubelet logs:
```bash
sudo journalctl -u kubelet -f
```

### Calico Pods Not Running

Check Calico pods:
```bash
kubectl get pods -n kube-system | grep calico
```

Describe problematic pod:
```bash
kubectl describe pod <POD_NAME> -n kube-system
```

### Worker Node Join Failed

Re-generate join command on control plane:
```bash
kubeadm token create --print-join-command
```

Copy and run on worker node:
```bash
sudo kubeadm reset  # If previously attempted
sudo <JOIN_COMMAND>
```

### SSH Connection Issues

Test SSH manually:
```bash
ssh -i /home/user/Downloads/my_server_01.pem ubuntu@<IP>
```

Check security groups in AWS console.

## Cleanup

### Reset Kubernetes Cluster

On each node:
```bash
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo rm -rf /home/ubuntu/.kube
```

### Or Use Terraform

Destroy entire infrastructure:
```bash
cd ../terraform
terraform destroy
```

## Files Generated

After running playbooks:
- `join-command.sh` - Join command for worker nodes (saved locally)

## Customization

### Change Kubernetes Version

Edit `hosts.ini`:
```ini
k8s_version=1.29  # Change to desired version
k8s_version_full=1.29.0-1.1
```

### Change Pod Network CIDR

Edit `hosts.ini`:
```ini
pod_network_cidr=10.244.0.0/16
```

Note: If changing from 192.168.0.0/16, you'll need to modify Calico manifest accordingly.

## Security Notes

1. **SSH Access**: Currently open to 0.0.0.0/0. Restrict in production.
2. **API Server**: Exposed on port 6443. Use firewall rules in production.
3. **NodePort Range**: 30000-32767 exposed. Secure in production.

## Next Steps

1. Install Ingress Controller (nginx, traefik)
2. Setup persistent storage (EBS CSI driver)
3. Install monitoring (Prometheus, Grafana)
4. Setup logging (EFK stack)
5. Configure RBAC and network policies

## References

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [containerd Documentation](https://containerd.io/docs/)
