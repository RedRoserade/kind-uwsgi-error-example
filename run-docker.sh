#!/usr/bin/env bash

MODE=http

docker build -t localhost:32000/test .

docker run -d --memory 512M -p 8080:8080 -e MODE=${MODE} --name test-uwsgi-docker --name test localhost:32000/test

echo "Container running."
echo "Now, try reaching it:"
echo "curl http://localhost:8080"
echo "When done, delete the container:"
echo "docker rm -f test"
