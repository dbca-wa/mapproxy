FROM python:3.10.13-slim-bullseye as builder_base_mapproxy
MAINTAINER asi@dbca.wa.gov.au
LABEL org.opencontainers.image.source https://github.com/dbca-wa/mapproxy

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y libproj-dev libgeos-dev libgdal-dev \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade pip

# Install Python libs using Poetry.
FROM builder_base_mapproxy as python_libs_mapproxy
WORKDIR /app
ENV POETRY_VERSION=1.5.1
RUN pip install --upgrade pip && pip install "poetry==$POETRY_VERSION"
COPY poetry.lock pyproject.toml /app/
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi --without dev

# Create a non-root user.
ARG UID=10001
ARG GID=10001
RUN groupadd -g "${GID}" appuser \
  && useradd --no-create-home --no-log-init --uid "${UID}" --gid "${GID}" appuser

# Install the project.
FROM python_libs_mapproxy
COPY gunicorn.py wsgi.py ./
RUN ln -s /app/config/mapproxy.yaml /app/mapproxy.yaml

USER ${UID}
EXPOSE 8080
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
