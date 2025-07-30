#!/bin/bash

set -e

echo "🔧 Creating namespace for cert-manager..."
kubectl apply -f manifests/cert-manager/namespace.yaml || true

echo "🔧 Adding Helm repo..."
helm repo add jetstack https://charts.jetstack.io
helm repo update

echo "🚀 Installing cert-manager via Helm..."
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

echo "✅ cert-manager installed successfully."