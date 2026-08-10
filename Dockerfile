# syntax=docker/dockerfile:1

# ---- Builder stage: compiliers and libraries ----
FROM dhi.io/python:3.13-debian13-dev AS builder

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
  gcc \
  g++ \
  gdal-bin \
  libgdal36 \
  libgeos-c1t64 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY gunicorn.py wsgi.py pyproject.toml uv.lock ./

COPY --from=ghcr.io/astral-sh/uv:0.12 /uv /bin/
RUN uv sync \
  --no-group dev \
  --link-mode=copy \
  --compile-bytecode \
  --no-python-downloads \
  --frozen \
  && rm -rf /bin/uv uv.lock

# ---- runtime stage: minimal packages needed to run the application ----
FROM dhi.io/python:3.13-debian13-dev AS runtime
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
COPY --from=builder --chown=nonroot:nonroot /app /app

ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PATH="/app/.venv/bin:$PATH"

USER nonroot
EXPOSE 8080
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
