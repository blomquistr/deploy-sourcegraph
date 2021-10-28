#! /bin/bash


# Create namespace
kubectl apply -f sourcegraph-namespace.yaml

# Deploy sourcegraph
./overlay-generate-cluster.sh namespaced generated-cluster
kubectl apply -n sourcegraph --prune -l deploy=sourcegraph -f generated-cluster --recursive

# Create sourcegraph StorageClass
cd base
# Create sourcegraph.StorageClass.yaml from https://docs.sourcegraph.com/admin/install/kubernetes/configure#configure-a-storage-class
kubectl apply -f sourcegraph.StorageClass.yaml

