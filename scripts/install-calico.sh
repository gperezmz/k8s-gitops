#!/usr/bin/env bash

set -exu -o pipefail

export ROUTER_BGP="192.168.0.1"
export CLUSTER_CIDR="10.42.0.0/16"
export SERVICE_CLUSTER_CIDR="10.43.0.0/16"
export SERVICE_EXTERNAL_CIDR="192.168.2.0/24"

kubectl apply -f https://docs.projectcalico.org/archive/v3.19/manifests/tigera-operator.yaml

cat <<EOF | kubectl apply -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: ${CLUSTER_CIDR}
      natOutgoing: Enabled
      nodeSelector: all()
  nodeMetricsPort: 9091
  typhaMetricsPort: 9093
EOF

cat <<EOF | kubectl apply -f -
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: bgppeer-global-64512
spec:
  peerIP: ${ROUTER_BGP}
  asNumber: 64512
EOF

cat <<EOF | kubectl apply -f -
apiVersion: crd.projectcalico.org/v1
kind: BGPConfiguration
metadata:
  name: default
spec:
  serviceClusterIPs:
  - cidr: ${SERVICE_CLUSTER_CIDR}
  serviceExternalIPs:
  - cidr: ${SERVICE_EXTERNAL_CIDR}
EOF
