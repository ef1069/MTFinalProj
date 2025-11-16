# Google Cloud Deployment Guide

This guide covers deploying MT Book Clubs to Google Cloud using either **Cloud Run** (serverless) or **GKE** (Kubernetes).

## Prerequisites

- Google Cloud Project with billing enabled
- `gcloud` CLI installed and authenticated
- `kubectl` installed (for GKE deployment)
- Docker images built and pushed to Container Registry or Artifact Registry

## Option 1: Cloud Run Deployment (Recommended for quick start)

Cloud Run is a fully managed serverless platform—great for apps that don't need constant uptime.

### Step 1: Set up GCP credentials and project

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
gcloud config set project $GCP_PROJECT_ID
gcloud auth login
```

### Step 2: Create secrets for environment variables

```bash
gcloud secrets create mongo-uri --replication-policy="automatic" \
  --data="mongodb+srv://user:password@cluster.mongodb.net/bookclubs"

gcloud secrets create jwt-secret --replication-policy="automatic" \
  --data="your-secret-jwt-key"
```

### Step 3: Build and push images using Cloud Build

```bash
gcloud builds submit --config=cloudbuild.yaml
```

This will build backend and frontend images and push them to `gcr.io/$PROJECT_ID/`.

### Step 4: Deploy to Cloud Run

```bash
# Deploy backend
gcloud run deploy mt-bookclubs-backend \
  --image gcr.io/$GCP_PROJECT_ID/mt-bookclubs-backend:latest \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated \
  --memory 512Mi \
  --timeout 300 \
  --set-env-vars MONGO_URI="mongodb+srv://...",JWT_SECRET="your-secret"

# Get backend service URL
BACKEND_URL=$(gcloud run services describe mt-bookclubs-backend \
  --platform managed --region us-central1 \
  --format='value(status.url)')

# Deploy frontend
gcloud run deploy mt-bookclubs-frontend \
  --image gcr.io/$GCP_PROJECT_ID/mt-bookclubs-frontend:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 256Mi \
  --timeout 300 \
  --set-env-vars VITE_API_URL="$BACKEND_URL"
```

### Step 5: Access the app

Frontend URL will be printed after deployment. Visit it in your browser.

## Option 2: GKE Deployment (For scale and control)

GKE is Kubernetes on Google Cloud—suitable for production workloads needing more control.

### Step 1: Create a GKE cluster

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"
export CLUSTER_NAME="bookclubs-gke"

gcloud config set project $GCP_PROJECT_ID

gcloud container clusters create $CLUSTER_NAME \
  --region $REGION \
  --num-nodes 3 \
  --machine-type n1-standard-2 \
  --enable-stackdriver-kubernetes
```

### Step 2: Get cluster credentials

```bash
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION
```

### Step 3: Build and push images

```bash
gcloud builds submit --config=cloudbuild.yaml
```

### Step 4: Create secrets

```bash
kubectl create namespace bookclubs

kubectl create secret generic mongo-secret -n bookclubs \
  --from-literal=uri="mongodb+srv://user:password@cluster.mongodb.net/bookclubs"

kubectl create secret generic jwt-secret -n bookclubs \
  --from-literal=secret="your-secret-jwt-key"
```

### Step 5: Deploy manifests

Update image references in `gcp/backend-deployment.yaml` and `gcp/frontend-deployment.yaml` to use your GCP project ID.

```bash
sed -i "s|PROJECT_ID|$GCP_PROJECT_ID|g" gcp/backend-deployment.yaml
sed -i "s|PROJECT_ID|$GCP_PROJECT_ID|g" gcp/frontend-deployment.yaml
```

Deploy:

```bash
kubectl apply -f gcp/mongo-deployment.yaml
kubectl apply -f gcp/backend-deployment.yaml
kubectl apply -f gcp/frontend-deployment.yaml
```

### Step 6: Access the app

Get the frontend LoadBalancer external IP:

```bash
kubectl get service frontend -n bookclubs -w
```

Once you have the external IP, visit `http://<external-ip>` in your browser.

## Monitoring & Logs

### Cloud Run logs

```bash
gcloud run services log read mt-bookclubs-backend --region us-central1
gcloud run services log read mt-bookclubs-frontend --region us-central1
```

### GKE logs

```bash
kubectl logs -n bookclubs deployment/backend -f
kubectl logs -n bookclubs deployment/frontend -f
```

## Database (MongoDB)

For production, use **MongoDB Atlas** (managed MongoDB service) rather than running MongoDB in a pod. Update `MONGO_URI` with your Atlas connection string.

## CI/CD with Cloud Build

The `cloudbuild.yaml` file automatically builds and pushes images when you push to your repository. To enable:

1. Connect your Git repo to Cloud Build
2. Create a build trigger pointing to this repo
3. Commits will auto-build and push images

## Tips & Next Steps

- Use **Cloud SQL Proxy** or **MongoDB Atlas** for production databases
- Add **Cloud Armor** for DDoS protection
- Set up **Cloud Load Balancing** for multi-region failover
- Use **Workload Identity** instead of service account keys for pod auth
- Add **Artifact Registry** for centralized image storage (instead of GCR)
