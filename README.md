run command terraform init

terraform plan

terraform apply

the ouptut of terrfarom will return the information:

Public IP of Bastion Host: 
External DNS of NLB
Internal DNS of NLB
External DNS of ALB

Connect to Bastion Host to config all cluster

With etcd, define a systemd file 

Note: change the IP follow the IP private of etcd cluser and run all cluster etcd
export name_cluster=''
export url_cluster='http://IP'

export ectd1=''
export ectd2=''
export ectd3=''



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

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

Check status with:

etcdctl endpoint health --cluster --endpoints=http://10.220.1.41:2379,http://10.220.2.191:2379,http://10.220.3.28:2379


On the control plane
check kubeadm-config 

sudo kubeadm init --config kube-config/kubeadm-config.yaml --upload-certs

Join remmain master

Join worker node