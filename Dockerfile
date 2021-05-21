FROM python:3.8.8-slim-buster as builder_base_mapproxy
MAINTAINER asi@dbca.wa.gov.au
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y python-pil python-yaml libproj-dev libgeos-dev python-lxml libgdal-dev python-shapely \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade pip

# Install Python libs from requirements.txt.
FROM builder_base_mapproxy as python_libs_mapproxy
WORKDIR /app
ENV POETRY_VERSION=1.1.6
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
