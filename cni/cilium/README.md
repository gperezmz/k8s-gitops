# Cilium CNI

```bash
helm repo add cilium https://helm.cilium.io/
```

Deploy cilium release via helm:

```bash
helm install cilium cilium/cilium \
  --version 1.9.2 \
  --namespace kube-system \
  -f values.yaml
```

Upgrade cilium release via helm:

Uncomment from `values.yaml` the first line `# upgradeCompatibility: '1.9'`

```bash
helm upgrade cilium cilium/cilium \
  --version <X.X.X> \
  --namespace=kube-system \
  -f values.yaml
```