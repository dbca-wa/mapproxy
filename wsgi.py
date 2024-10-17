# WSGI module for use with uWSGI or gunicorn
from mapproxy.wsgiapp import make_wsgi_app

application = make_wsgi_app("config/mapproxy.yaml")
