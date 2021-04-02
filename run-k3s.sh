#!/usr/bin/env bash

set -e

docker build -t localhost:32000/test .

# Load image (thanks to https://cwienczek.com/2020/06/import-images-to-k3s-without-docker-registry/)

docker save localhost:32000/test -o test.tar

sudo k3s ctr images import test.tar

rm test.tar

kubectl delete -f pod.yaml || true

kubectl create -f pod.yaml

echo "Pod created"
echo "Now exec into it:"
echo "kubectl exec -it example-pod -- bash"
echo "And try to reach the server with:" 
echo "curl http://localhost:8080"
echo "When done, cleanup with:"
echo "kubectl delete -f pod.yaml"
