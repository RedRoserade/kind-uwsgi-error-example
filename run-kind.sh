#!/usr/bin/env bash

docker build -t localhost:32000/test .

kind load docker-image localhost:32000/test

kubectl create -f pod.yaml

echo "Pod created"
echo "Now exec into it:"
echo "kubectl exec -it example-pod -- bash"
echo "And try to reach the server with:" 
echo "curl http://localhost:8080"
echo "When done, cleanup with:"
echo "kubectl delete -f pod.yaml"