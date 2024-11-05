import logging

from mapproxy.wsgiapp import make_wsgi_app

# Configure logging.
logging.config.fileConfig("config/log.ini")

# Set the logging level for all azure-* libraries (the azure-storage-blob library uses this one).
# Reference: https://learn.microsoft.com/en-us/azure/developer/python/sdk/azure-sdk-logging
azure_logger = logging.getLogger("azure")
azure_logger.setLevel(logging.WARNING)

# WSGI module for use with uWSGI or gunicorn
application = make_wsgi_app("config/mapproxy.yaml")
