# syntax=docker/dockerfile:1
# Args to centralise versions.
ARG PYTHON_VERSION=3.13-debian13-dev

# ---- Builder stage ----
FROM dhi.io/python:${PYTHON_VERSION} AS builder

RUN <<EOF
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends \
  gcc \
  g++ \
  gdal-bin \
  libgdal36 \
  libgeos-c1t64
EOF

WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:0.13 /uv /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --no-group dev --link-mode=copy --compile-bytecode --no-python-downloads --frozen

# ---- runtime stage: minimal packages needed to run the application ----
FROM dhi.io/python:${PYTHON_VERSION} AS runtime
LABEL org.opencontainers.image.source="https://github.com/dbca-wa/mapproxy" \
  org.opencontainers.image.description="DBCA MapProxy" \
  org.opencontainers.image.vendor="DBCA" \
  org.opencontainers.image.authors="asi@dbca.wa.gov.au"

RUN <<EOF
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends \
  gdal-bin \
  libgdal36 \
  libgeos-c1t64
ldconfig
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

# Environment variables
ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PATH="/app/.venv/bin:$PATH"

WORKDIR /app
# Copy installed virtualenv from builder
COPY --from=builder --chown=nonroot:nonroot /app /app

# Copy the remaining project files to finish building the project
COPY --chown=nonroot:nonroot gunicorn.py pyproject.toml wsgi.py ./

USER nonroot
EXPOSE 8080
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
