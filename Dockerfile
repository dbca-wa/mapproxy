# syntax=docker/dockerfile:1

# ---- Builder stage ----
FROM dhi.io/python:3.13-debian13-dev AS builder-mapproxy

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
  gdal-bin \
  libgdal36 \
  libgeos-c1t64 \
  gcc \
  g++ \
  && rm -rf /var/lib/apt/lists/*

# Import uv to install dependencies
COPY --from=ghcr.io/astral-sh/uv:0.11 /uv /bin/
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync \
  --no-group dev \
  --link-mode=copy \
  --compile-bytecode \
  --no-python-downloads \
  --frozen \
  && rm -rf /bin/uv uv.lock

# ---- Runtime stage ----
FROM dhi.io/python:3.13-debian13-dev
LABEL org.opencontainers.image.authors=asi@dbca.wa.gov.au
LABEL org.opencontainers.image.source=https://github.com/dbca-wa/mapproxy

# Install system packages required to run the project
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
  gdal-bin \
  libgdal36 \
  libgeos-c1t64 \
  # Run shared library linker after installing spatial packages
  && ldconfig \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Environment variables
ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Copy installed virtualenv from builder-mapproxy
COPY --from=builder-mapproxy /app /app

# Copy the remaining project files to finish building the project
COPY --chown=nonroot:nonroot gunicorn.py wsgi.py ./

# Run the project as the nonroot user
USER nonroot
EXPOSE 8080
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
