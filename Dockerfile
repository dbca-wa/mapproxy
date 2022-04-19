FROM python:3.9.11-slim-bullseye as builder_base
MAINTAINER asi@dbca.wa.gov.au
LABEL org.opencontainers.image.source https://github.com/dbca-wa/mapproxy

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y libproj-dev libgeos-dev libgdal-dev \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade pip

# Install Python libs from requirements.txt.
FROM builder_base as python_libs_mapproxy
WORKDIR /app
ENV POETRY_VERSION=1.1.13
RUN pip install "poetry==$POETRY_VERSION"
RUN python -m venv /venv
COPY poetry.lock pyproject.toml /app/
RUN poetry config virtualenvs.create false \
  && poetry install --no-dev --no-interaction --no-ansi

# Install the project.
FROM python_libs_mapproxy
COPY gunicorn.py wsgi.py ./
RUN ln -s /app/config/mapproxy.yaml /app/mapproxy.yaml
USER www-data
EXPOSE 8080
HEALTHCHECK --interval=1m --timeout=5s --start-period=10s --retries=3 CMD ["wget", "-q", "-O", "-", "http://localhost:8080/demo/"]
CMD ["gunicorn", "--config", "gunicorn.py", "wsgi"]
