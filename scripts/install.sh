#!/bin/bash

set -e

echo "🚀 Starting ArgoCD Bootstrap..."

# Step 1: Create namespace
kubectl create ns argocd || true

# Step 2: Install cert-manager
bash manifests/cert-manager/cert-manager-helm-install.sh

# Step 3: Apply ClusterIssuer
kubectl apply -f manifests/cert-manager/cert-issuer.yaml

# Step 4: Install ArgoCD core
kubectl apply -n argocd -f manifests/install-argocd.yaml
# ✅ NEW: Wait for the argocd-server service to appear
echo "⏳ Waiting for argocd-server service to be created..."
kubectl wait --for=condition=available --timeout=90s deployment/argocd-server -n argocd || true
sleep 10


# Step 5: Patch argocd-server
kubectl patch svc argocd-server -n argocd --patch-file manifests/patch-argocd-service.yaml

# Step 6: Apply ArgoCD Ingress
kubectl apply -f manifests/ingress/argocd-ingress.yaml

echo "✅ All components installed. Access ArgoCD at: https://argocd-app.opt.dev.mafteiops.com"