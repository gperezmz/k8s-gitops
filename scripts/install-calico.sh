#!/usr/bin/env bash

set -exu -o pipefail

export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export K8S_SVC_HOST=$(ip a | grep global | grep -v tun | awk '{print $2}' | cut -f1 -d '/')
export K8S_SVC_PORT=6443

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubernetes-services-endpoint
  namespace: kube-system
data:
  KUBERNETES_SERVICE_HOST: "${K8S_SVC_HOST}"
  KUBERNETES_SERVICE_PORT: "${K8S_SVC_PORT}"
EOF

sleep 3s;

kubectl apply -f https://docs.projectcalico.org/archive/v3.19/manifests/calico.yaml

until [ -f /etc/cni/net.d/10-calico.conflist ]
do
    sleep 1;
done

cat << EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: my.ippool-1
spec:
  blockSize: 26
  cidr: 10.42.0.0/16
  ipipMode: CrossSubnet
  natOutgoing: true
  nodeSelector: all()
EOF

cat << EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: bgppeer-global-64512
spec:
  peerIP: 192.168.0.1
  asNumber: 64512
EOF

cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  serviceClusterIPs:
  - cidr: 10.43.0.0/16
  serviceExternalIPs:
  - cidr: 192.168.2.0/24
EOF
