#!/bin/bash
set -e

# Disable swap (required by Kubernetes) 
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# [2] Enable required kernel modules 
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

modprobe br_netfilter

# [3] Configure sysctl for Kubernetes networking 
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# [4] Install required packages 
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

# [5] Install Kubernetes components (kubeadm, kubelet, kubectl) 
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" 
| tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# [6] Install containerd 
wget https://github.com/containerd/containerd/releases/download/v2.2.2/containerd-2.2.2-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-2.2.2-linux-amd64.tar.gz

mkdir -p /usr/local/lib/systemd/system

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /usr/local/lib/systemd/system/

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now containerd

# [7] Install runc 
wget https://github.com/opencontainers/runc/releases/download/v1.4.1/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

# [8] Configure containerd to use systemd cgroup 
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd

# [9] Initialize Kubernetes cluster 
kubeadm init --pod-network-cidr=192.168.0.0/16

# [10] Configure kubectl for ubuntu user 
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# [11] Install Calico CNI (VXLAN mode to avoid BGP issues) 
su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml"

# [12] Patch Calico to use VXLAN instead of BGP 
sleep 10
su - ubuntu -c "kubectl patch ippool default-ipv4-ippool -p '{"spec": {"vxlanMode": "Always", "ipipMode": "Never"}}'"
