MapProxy service application
============================

Basic MapProxy service used internally by the Department of Biodiversity,
Conservation and Attractions.

# Docker image

To build a new Docker image from the `Dockerfile`:

    docker image build -t ghcr.io/dbca-wa/mapproxy .

# Running Docker container

When running this image as a container, provide a configuration file
mounted at `/app/config/mapproxy.yaml` (this can be a bind-mounted
local file or a ConfigMap in Kubernetes).

Example using a local bind-mount file:

    docker container run -p 8080:8080 -v $PWD/mapproxy.yaml:/app/config/mapproxy.yaml ghcr.io/dbca-wa/mapproxy
