# syntax=docker/dockerfile:1
# Prepare the base environment.
FROM python:3.12.8-slim AS builder_base_mapproxy
LABEL org.opencontainers.image.authors=asi@dbca.wa.gov.au
LABEL org.opencontainers.image.source=https://github.com/dbca-wa/mapproxy

RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y libgeos-dev libgdal-dev \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --root-user-action=ignore --no-cache-dir --upgrade pip

# Install Python libs using Poetry.
FROM builder_base_mapproxy AS python_libs_mapproxy
WORKDIR /app
ARG POETRY_VERSION=1.8.5
RUN pip install --root-user-action=ignore --no-cache-dir poetry==${POETRY_VERSION}
COPY poetry.lock pyproject.toml ./
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi --only main

# Create a non-root user.
ARG UID=10001
ARG GID=10001
RUN groupadd -g "${GID}" appuser \
  && useradd --no-create-home --no-log-init --uid ${UID} --gid ${GID} appuser

# Install the project.
FROM python_libs_mapproxy
COPY gunicorn.py wsgi.py ./

USER ${UID}
EXPOSE 8080
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
