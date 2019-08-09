FROM ubuntu:18.04 as builder_base_mapproxy
MAINTAINER asi@dbca.wa.gov.au
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y wget git libmagic-dev gcc binutils libproj-dev gdal-bin \
  python python-setuptools python-dev python-pip tzdata libjpeg-dev zlib1g-dev libpng-dev \
  && pip install --upgrade pip

# Install Python libs from requirements.txt.
FROM builder_base_mapproxy as python_libs_mapproxy
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install the project.
FROM python_libs_mapproxy
COPY mapproxy.yaml uwsgi.ini wsgi.py ./
USER www-data
EXPOSE 8080
HEALTHCHECK --interval=1m --timeout=5s --start-period=10s --retries=3 CMD ["wget", "-q", "-O", "-", "http://localhost:8080/demo/"]
CMD ["uwsgi", "--ini", "/app/uwsgi.ini"]
