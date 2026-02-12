# syntax=docker/dockerfile:1
FROM dhi.io/python:3.13-debian13-dev AS build-stage
LABEL org.opencontainers.image.authors=asi@dbca.wa.gov.au
LABEL org.opencontainers.image.source=https://github.com/dbca-wa/mapproxy

# Install system packages required to run the project
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends gdal-bin libgdal36 libgeos-c1t64 \
  # Run shared library linker after installing packages
  && ldconfig \
  && rm -rf /var/lib/apt/lists/*

# Import uv to install dependencies
COPY --from=ghcr.io/astral-sh/uv:0.9 /uv /bin/
WORKDIR /app
# Install project dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --no-group dev --link-mode=copy --compile-bytecode --no-python-downloads --frozen \
  # Remove uv and lockfile after use
  && rm -rf /bin/uv \
  && rm uv.lock

# Copy the remaining project files to finish building the project
COPY gunicorn.py wsgi.py ./
ENV PYTHONUNBUFFERED=1
ENV PATH="/app/.venv/bin:$PATH"

# Run the project as the nonroot user
USER nonroot
EXPOSE 8080
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
