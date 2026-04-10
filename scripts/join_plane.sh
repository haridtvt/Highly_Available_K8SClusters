#!/bin/bash
set -e

# [01] On the master node 01, using kubeadm to init with DNS_NLB andh setup config
kubeadm init --control-plane-endpoint "${DNS_NLB}:6443"   --upload-certs  --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# [03] all master node
## Install Calico CNI (VXLAN mode to avoid BGP issues)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml

## Patch Calico to use VXLAN instead of BGP
sleep 10
kubectl patch ippool default-ipv4-ippool --type='merge' -p '{"spec": {"vxlanMode": "Always", "ipipMode": "Never"}}' -n kube-system

