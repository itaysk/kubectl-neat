.spec.volumes[] | select(.name | startswith("default-token-"))
.spec.containers[].volumeMounts[] | select(.name | startswith("default-token-"))
.metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"]
.spec.nodeName
