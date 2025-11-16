#!/bin/bash
set -e

# Configuration
PROJECT_ID=${GCP_PROJECT_ID:-"your-gcp-project-id"}
REGION="us-central1"
SERVICE_BACKEND="mt-bookclubs-backend"
SERVICE_FRONTEND="mt-bookclubs-frontend"

echo "Deploying MT Book Clubs to Google Cloud Run..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"

# Set the project
gcloud config set project $PROJECT_ID

# Create secrets (if they don't exist)
echo "Creating/updating secrets..."
gcloud secrets versions add mongo-uri --data="mongodb+srv://user:pass@cluster.mongodb.net/bookclubs?retryWrites=true&w=majority" 2>/dev/null || \
gcloud secrets create mongo-uri --replication-policy="automatic" --data="mongodb+srv://user:pass@cluster.mongodb.net/bookclubs?retryWrites=true&w=majority"

gcloud secrets versions add jwt-secret --data="your-super-secret-jwt-key-change-in-prod" 2>/dev/null || \
gcloud secrets create jwt-secret --replication-policy="automatic" --data="your-super-secret-jwt-key-change-in-prod"

# Build and push images to Artifact Registry
echo "Building and pushing images to Artifact Registry..."
gcloud builds submit --config=cloudbuild.yaml

# Deploy backend to Cloud Run
echo "Deploying backend to Cloud Run..."
gcloud run deploy $SERVICE_BACKEND \
  --image gcr.io/$PROJECT_ID/$SERVICE_BACKEND:latest \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --set-env-vars MONGO_URI=mongodb+srv://...,JWT_SECRET=... \
  --service-account=$SERVICE_BACKEND-sa

# Deploy frontend to Cloud Run
echo "Deploying frontend to Cloud Run..."
BACKEND_URL=$(gcloud run services describe $SERVICE_BACKEND --platform managed --region $REGION --format='value(status.url)')

gcloud run deploy $SERVICE_FRONTEND \
  --image gcr.io/$PROJECT_ID/$SERVICE_FRONTEND:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 256Mi \
  --cpu 1 \
  --timeout 300 \
  --set-env-vars VITE_API_URL=$BACKEND_URL \
  --service-account=$SERVICE_FRONTEND-sa

echo "Deployment complete!"
echo "Frontend URL: $(gcloud run services describe $SERVICE_FRONTEND --platform managed --region $REGION --format='value(status.url)')"
echo "Backend URL: $BACKEND_URL"
