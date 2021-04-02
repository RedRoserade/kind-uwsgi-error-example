FROM python:3.9-buster

# `htop` for debugging
RUN apt-get update && apt-get install htop
# RUN apk add --no-cache htop bash python3-dev build-base linux-headers pcre-dev

# Install dependencies
RUN pip install uwsgi flask

COPY docker-entrypoint.sh app.py /

# http or http-socket
ENV MODE="http"

EXPOSE 8080

ENTRYPOINT [ "/docker-entrypoint.sh" ]
