<img width="1212" height="620" alt="chart_cluster" src="https://github.com/user-attachments/assets/e3901c92-4bbf-47b6-b209-ff5f55f1ee97" />


# Infrastructure Provisioning (Terraform)

This repository contains Terraform configuration and deployment guidance for provisioning a Kubernetes cluster with a bastion host, load balancers, and an etcd cluster.

## Terraform Configuration

### 1. Create `terraform.tfvars`

```hcl
region     = "ap-southeast-1"
access_key = "XXXX"
secret_key = "XXXXXXX"
ami_id     = "XXX"
```

### 2. Initialize Terraform

```shell
terraform init
```

### 3. Review the execution plan

```shell
terraform plan
```

### 4. Apply infrastructure

```shell
terraform apply
```

## Terraform Outputs

After deployment, Terraform will return the following values:

- Public IP of the bastion host
- External DNS of the Network Load Balancer (NLB)
- Internal DNS of the NLB
- External DNS of the Application Load Balancer (ALB)

## Access & Bastion Host

Connect to the bastion host using the public IP address:

```shell
ssh ubuntu@<BASTION_PUBLIC_IP>
```

Use the bastion host to access and configure all cluster nodes.

## etcd Cluster Setup

> Replace variables with your actual private IPs of etcd nodes and appropriate cluster names.

Create the systemd service for etcd:

```shell
cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --name ${name_cluster} \
    --initial-advertise-peer-urls ${url_cluster}:2380 \
    --listen-peer-urls ${url_cluster}:2380 \
    --listen-client-urls ${url_cluster}:2379,http://127.0.0.1:2379 \
    --advertise-client-urls ${url_cluster}:2379 \
    --initial-cluster-token etcd-cluster-1 \
    --initial-cluster etcd-node-1=${etcd1},etcd-node-2=${etcd2},etcd-node-3=${etcd3} \
    --initial-cluster-state new --data-dir=/var/lib/etcd
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start etcd:

```shell
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
```

Verify etcd cluster health:

```shell
etcdctl endpoint health --cluster \
  --endpoints=http://10.220.1.41:2379,http://10.220.2.191:2379,http://10.220.3.28:2379
```

## Kubernetes Control Plane Initialization

Run kubeadm to initialize the control plane:

```shell
sudo kubeadm init --config kube-config/kubeadm-config.yaml --upload-certs
```

This command generates:

- Join command for additional control-plane nodes
- Join command for worker nodes

Save these commands for later use.

## Joining Cluster Nodes

### Join additional control plane nodes

Run the generated control-plane join command on each additional master node.

### Join worker nodes

Run the generated worker join command on each worker node.

## Cluster Verification

Verify the cluster state once nodes have joined:

```shell
kubectl get nodes
kubectl get pods -A
```

## TODO

- Automate configuration using Ansible
- Implement etcd backup to S3
