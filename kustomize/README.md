# MapProxy Kubernetes Kustomize overlay configuration

Declarative management of MapProxy Kubernetes resources using Kustomize.

# How to use

Within an overlay directory, create a `config.yaml` file to configure the
proxied tile layers.

Review the built resource output using `kustomize`:

```bash
kustomize build kustomize/overlays/uat/ | less
```

Run `kubectl` with the `-k` flag to generate resources for a given overlay:

```bash
kubectl apply -k kustomize/overlays/uat --namespace sss --dry-run=client
```

# References:

* https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
* https://github.com/kubernetes-sigs/kustomize
* https://github.com/kubernetes-sigs/kustomize/tree/master/examples
