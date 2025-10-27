# MapProxy service application

Basic MapProxy service used internally by the Department of Biodiversity,
Conservation and Attractions.

## Development

Development of the containerised application is based on the
installation instructions in the MapProxy documentation:
<https://mapproxy.github.io/mapproxy/latest/install.html>

Additional reference can be made to the GitHub project Dockerfile:
<https://github.com/mapproxy/mapproxy/blob/master/docker/Dockerfile>

Dependencies for this project are managed using [uv](https://docs.astral.sh/uv/).
With uv installed, change into the project directory and run:

    uv sync

Activate the virtualenv like so:

    source .venv/bin/activate

To run Python commands in the activated virtualenv, thereafter run them like so:

    python manage.py

Manage new or updated project dependencies with uv also, like so:

    uv add newpackage==1.0

## MapProxy configuration

To configure the local MapProxy server, create a `config` directory in the project directory
(relative to `wsgi.py`) and create the following configuration files in there:

- mapproxy.yaml
- logging.ini
- seed.yaml (optional)

MapProxy configuration reference: <https://mapproxy.github.io/mapproxy/latest/configuration.html>

## Docker image

To build a new Docker image from the `Dockerfile`:

    docker image build -t ghcr.io/dbca-wa/mapproxy .

## Running Docker container

When running this image as a container, provide a configuration file
mounted at `/app/config/mapproxy.yaml` (this can be a bind-mounted
local file or a ConfigMap in Kubernetes).

Example using local configuration files bind-mounted into the container:

    docker container run -p 8080:8080 -v $PWD/config/mapproxy.yaml:/app/config/mapproxy.yaml -v $PWD/config/logging.ini:/app/config/logging.ini ghcr.io/dbca-wa/mapproxy
