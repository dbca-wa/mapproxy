MapProxy service application
============================

Basic MapProxy service used internally by the Department of Biodiversity,
Conservation and Attractions.

# Running Docker container

When running this image as a container or workload, remember to provide a
configuration file at `/app/config/mapproxy.yaml` (this can be a bind-mounted
local file or a configmap in Kubernetes).

Example:

    docker container run -p 8080:8080 -v $PWD/mapproxy.yaml:/app/config/mapproxy.yaml ghcr.io/dbca-wa/mapproxy
