#!/bin/bash
set -e

ETCD_VERSION="v3.5.24"
ETCD_NAME="etcd-1"
ETCD_IP=$(hostname -I | awk '{print $1}')

# Install etcd
cd /tmp
wget -q https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar -xvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin/

