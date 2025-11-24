#!/usr/bin/env bash
set -euo pipefail

# Paths
FRONT_DIR="./frontend"
BACK_DIR="./backend"

# Images
FRONT_IMG="frontend:latest"
BACK_IMG="backend:latest"

echo "1/8 — Starting minikube (if not running)..."
minikube status >/dev/null 2>&1 || minikube start

echo "2/8 — Using minikube's docker daemon for local image build..."
# For bash/zsh. This sets DOCKER env vars in this shell only.
eval $(minikube -p minikube docker-env)

echo "3/8 — Building backend image..."
docker build -t ${BACK_IMG} ${BACK_DIR}

echo "4/8 — Building frontend image..."
docker build -t ${FRONT_IMG} ${FRONT_DIR}

echo "5/8 — Applying Kubernetes manifests..."
kubectl apply -f k8s.yaml

echo "6/8 — Waiting for pods to be ready..."
kubectl -n demo-app wait --for=condition=available deploy/backend-deployment --timeout=120s || true
kubectl -n demo-app wait --for=condition=available deploy/frontend-deployment --timeout=120s || true

echo "7/8 — Showing pods:"
kubectl -n demo-app get pods -o wide

echo "8/8 — Expose frontend to browser using minikube service"
echo "Opening frontend in browser..."
minikube service --namespace demo-app frontend-svc

echo "Done. If the browser did not open, run: minikube service --namespace demo-app frontend-svc"
