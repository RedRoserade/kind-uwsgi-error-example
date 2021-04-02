#!/usr/bin/env bash

set -e

MODE=http

CONTAINER_NAME=test-mem-usage

docker build -t localhost:32000/test .

docker rm -f ${CONTAINER_NAME} || true

docker run -d --memory 512M -p 8080:8080 -e MODE=${MODE} --name test-uwsgi-docker --name ${CONTAINER_NAME} localhost:32000/test

echo "Container running."
echo "Now, try reaching it:"
echo "curl http://localhost:8080"
echo "When done, delete the container:"
echo "docker rm -f ${CONTAINER_NAME}"
