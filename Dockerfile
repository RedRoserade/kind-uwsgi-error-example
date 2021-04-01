FROM python:3.8-buster

# `htop` for debugging
RUN apt-get update && apt-get install htop

# Install dependencies
RUN pip install uwsgi flask

COPY docker-entrypoint.sh app.py /

# http or http-socket
ENV MODE="http"

EXPOSE 8080

ENTRYPOINT [ "/docker-entrypoint.sh" ]
