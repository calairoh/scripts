# k8s-pf.sh

A script to simplify Kubernetes port-forwarding by automatically finding a pod by a partial name and forwarding a specified port.

## What It Does
- Searches for pods in a given namespace that match a partial pod name.
- If multiple pods match, prompts you to select one.
- Forwards a local port to a pod port using `kubectl port-forward`.

## Usage

```bash
./k8s-pf.sh <partial-pod-name> <local-port>:<pod-port> <namespace>
```

### Example
```bash
./k8s-pf.sh crud-service 3001:3000 p4samd-governance-jam
```

This will search for pods containing `crud-service` in the namespace `p4samd-governance-jam` and forward local port 3001 to pod port 3000.

## Requirements
- Bash shell
- `kubectl` installed and configured
- Access to the target Kubernetes cluster

## Notes
- If no pods match, the script exits with an error.
- If multiple pods match, you will be prompted to select one.
- The script runs `kubectl port-forward` for the selected pod.
