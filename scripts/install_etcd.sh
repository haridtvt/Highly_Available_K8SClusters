#!/bin/bash
set -e


# Create systemd service

cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --name etcd-node-3 --initial-advertise-peer-urls http://10.220.3.28:2380 --listen-peer-urls http://10.220.3.28:2380 --listen-client-urls http://10.220.3.28:2379,http://127.0.0.1:2379 --advertise-client-urls http://10.220.3.28:2379 --initial-cluster-token etcd-cluster-1 --initial-cluster etcd-node-1=http://10.220.1.41:2380,etcd-node-2=http://10.220.2.191:2380,etcd-node-3=http://10.220.3.28:2380 --initial-cluster-state new --data-dir=/var/lib/etcd
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# Start etcd

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

# Checking
etcdctl endpoint health --cluster --endpoints=http://10.220.1.41:2379,http://10.220.2.191:2379,http://10.220.3.28:2379
