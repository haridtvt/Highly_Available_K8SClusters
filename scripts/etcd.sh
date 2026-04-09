#!/bin/bash
set -e

ETCD_VERSION="v3.5.12"
ETCD_NAME="etcd-1"
ETCD_IP=$(hostname -I | awk '{print $1}')

# Install etcd
cd /tmp
wget -q https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar -xvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin/

mkdir -p /var/lib/etcd
mkdir -p /etc/etcd/pki
cd /etc/etcd/pki

# Generate CA
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key \
  -subj "/CN=etcd-ca" \
  -days 10000 -out ca.crt

# Generate server cert (etcd)
cat > server-openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
IP.1 = ${ETCD_IP}
IP.2 = 127.0.0.1
DNS.1 = ${NLB_DNS}
EOF

openssl genrsa -out server.key 2048

openssl req -new -key server.key \
  -subj "/CN=${ETCD_NAME}" \
  -out server.csr \
  -config server-openssl.cnf

openssl x509 -req -in server.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt -days 365 \
  -extensions v3_req -extfile server-openssl.cnf

# Generate client cert (for kube-apiserver)
openssl genrsa -out apiserver-etcd-client.key 2048

openssl req -new -key apiserver-etcd-client.key \
  -subj "/CN=apiserver-etcd-client" \
  -out client.csr

openssl x509 -req -in client.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out apiserver-etcd-client.crt -days 365

# Create systemd service

cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --data-dir /var/lib/etcd \\
  --listen-client-urls https://0.0.0.0:2379 \\
  --advertise-client-urls https://${ETCD_IP}:2379 \\
  --cert-file=/etc/etcd/pki/server.crt \\
  --key-file=/etc/etcd/pki/server.key \\
  --trusted-ca-file=/etc/etcd/pki/ca.crt \\
  --client-cert-auth=true

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# Start etcd

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd