# MapProxy Kubernetes Kustomize overlay configuration

Declarative management of MapProxy Kubernetes resources using Kustomize.

## How to use

Within each overlay directory, create a `mapproxy.yaml` file to configure the
proxied tile layers and a `seed.yaml` to configure behaviour of the
`mapproxy-seed` tool. Reference:

- <https://mapproxy.github.io/mapproxy/latest/configuration.html>

Review the built resource output using `kustomize`:

```bash
kustomize build kustomize/overlays/uat/ | less
```

Run `kubectl` with the `-k` flag to generate resources for a given overlay:

```bash
kubectl apply -k kustomize/overlays/uat --namespace mapproxy --dry-run=client
```

## References

- <https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/>
- <https://github.com/kubernetes-sigs/kustomize>
- <https://github.com/kubernetes-sigs/kustomize/tree/master/examples>
