#!/bin/bash

set -e

echo "🔧 Creating namespace for cert-manager..."
kubectl get ns cert-manager >/dev/null 2>&1 || kubectl create ns cert-manager

echo "🔧 Adding Helm repo..."
helm repo add jetstack https://charts.jetstack.io || true
helm repo update

echo "🚀 Installing cert-manager via Helm..."
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --version v1.18.2

echo "✅ cert-manager installed successfully."

echo "🔧 Applying ClusterIssuer..."
kubectl apply -f manifests/ingress/cert-issuer.yaml

echo "🔧 Creating namespace for ArgoCD..."
kubectl get ns argocd >/dev/null 2>&1 || kubectl create ns argocd

echo "🚀 Installing ArgoCD core components..."
kubectl apply -n argocd -f manifests/install-argocd.yaml

echo "⏳ Waiting for argocd-server service to be created..."
until kubectl get svc argocd-server -n argocd >/dev/null 2>&1; do
  echo "Waiting for argocd-server service..."
  sleep 5
done

echo "🔧 Patching argocd-server service to ClusterIP..."
kubectl patch svc argocd-server -n argocd --patch-file manifests/patch-argocd-service.yaml

echo "🌐 Applying Ingress for ArgoCD..."
kubectl apply -f manifests/ingress/argocd-ingress.yaml

echo "✅ ArgoCD is now bootstrapped at https://argocd-app.opt.dev.mafteiops.com"