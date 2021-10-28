This kustomization deletes resource declarations and storage classnames to enable runnning Sourcegraph on minikube.

Starting Sourcegraph:

To use it, execute the following command from the root directory of this repository:

```shell script
./overlay-generate-cluster.sh minikube generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
minikube start
kubectl create namespace sourcegraph
kubectl -n sourcegraph apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
kubectl -n sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --port=3080 --target-port=3080
minikube service list
``` 

Tearing it down:

```shell script
kubectl delete namespaces sourcegraph
minikube stop
``` 
