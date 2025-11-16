#!/bin/bash
set -e

# Configuration
PROJECT_ID=${GCP_PROJECT_ID:-"your-gcp-project-id"}
REGION="us-central1"
CLUSTER_NAME="bookclubs-gke"
IMAGE_TAG="latest"

echo "Deploying MT Book Clubs to Google Kubernetes Engine (GKE)..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Cluster: $CLUSTER_NAME"

# Set the project
gcloud config set project $PROJECT_ID

# Create GKE cluster if it doesn't exist
echo "Checking/creating GKE cluster..."
if ! gcloud container clusters describe $CLUSTER_NAME --region $REGION &>/dev/null; then
  echo "Creating GKE cluster $CLUSTER_NAME..."
  gcloud container clusters create $CLUSTER_NAME \
    --region $REGION \
    --num-nodes 3 \
    --machine-type n1-standard-2 \
    --enable-stackdriver-kubernetes \
    --addons HttpLoadBalancing,HttpsLoadBalancing
fi

# Get cluster credentials
echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

# Build and push images
echo "Building and pushing images..."
gcloud builds submit --config=cloudbuild.yaml

# Create namespace
kubectl create namespace bookclubs --dry-run=client -o yaml | kubectl apply -f -

# Create secrets
echo "Creating secrets..."
kubectl create secret generic mongo-secret \
  --from-literal=uri="mongodb+srv://user:pass@cluster.mongodb.net/bookclubs" \
  -n bookclubs \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic jwt-secret \
  --from-literal=secret="your-super-secret-jwt-key-change-in-prod" \
  -n bookclubs \
  --dry-run=client -o yaml | kubectl apply -f -

# Update image references in manifests
echo "Updating image references..."
sed -i "s|PROJECT_ID|$PROJECT_ID|g" gcp/backend-deployment.yaml
sed -i "s|PROJECT_ID|$PROJECT_ID|g" gcp/frontend-deployment.yaml

# Deploy MongoDB, backend, and frontend
echo "Deploying MongoDB..."
kubectl apply -f gcp/mongo-deployment.yaml

echo "Deploying backend..."
kubectl apply -f gcp/backend-deployment.yaml

echo "Deploying frontend..."
kubectl apply -f gcp/frontend-deployment.yaml

# Wait for services to be ready
echo "Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n bookclubs
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n bookclubs

# Get frontend service external IP
echo "Getting frontend service external IP..."
kubectl get service frontend -n bookclubs

echo "Deployment to GKE complete!"
echo "Access the frontend via the external IP/LoadBalancer endpoint shown above."
