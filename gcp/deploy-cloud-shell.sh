#!/bin/bash
set -e

# Cloud Shell deployment script for MT Book Clubs
# Run this in Google Cloud Shell after cloning the repo
# Usage: bash gcp/deploy-cloud-shell.sh

echo "=== MT Book Clubs — Cloud Run Deployment ==="
echo ""

# Set variables (replace with your own)
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
MONGO_URI="${MONGO_URI:-mongodb+srv://user:password@cluster.mongodb.net/bookclubs}"
JWT_SECRET="${JWT_SECRET:-your-secret-jwt-key}"

if [ -z "$PROJECT_ID" ]; then
  echo "ERROR: GCP project not set. Run: gcloud config set project YOUR_PROJECT_ID"
  exit 1
fi

echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""

# Step 1: Enable required APIs
echo "Step 1: Enabling APIs..."
gcloud services enable run.googleapis.com cloudbuild.googleapis.com containerregistry.googleapis.com --project=$PROJECT_ID
echo "✓ APIs enabled"
echo ""

# Step 2: Build and push images
echo "Step 2: Building and pushing Docker images..."
gcloud builds submit --config=cloudbuild.yaml --project=$PROJECT_ID
echo "✓ Images built and pushed to gcr.io/$PROJECT_ID/"
echo ""

# Step 3: Deploy backend
echo "Step 3: Deploying backend to Cloud Run..."
gcloud run deploy mt-bookclubs-backend \
  --image gcr.io/$PROJECT_ID/mt-bookclubs-backend:latest \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --memory 512Mi \
  --timeout 300 \
  --set-env-vars MONGO_URI="$MONGO_URI",JWT_SECRET="$JWT_SECRET" \
  --project=$PROJECT_ID
echo "✓ Backend deployed"
echo ""

# Get backend URL
BACKEND_URL=$(gcloud run services describe mt-bookclubs-backend \
  --platform managed \
  --region $REGION \
  --format='value(status.url)' \
  --project=$PROJECT_ID)

echo "Backend URL: $BACKEND_URL"
echo ""

# Step 4: Deploy frontend
echo "Step 4: Deploying frontend to Cloud Run..."
gcloud run deploy mt-bookclubs-frontend \
  --image gcr.io/$PROJECT_ID/mt-bookclubs-frontend:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 256Mi \
  --timeout 300 \
  --set-env-vars VITE_API_URL="$BACKEND_URL" \
  --project=$PROJECT_ID
echo "✓ Frontend deployed"
echo ""

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe mt-bookclubs-frontend \
  --platform managed \
  --region $REGION \
  --format='value(status.url)' \
  --project=$PROJECT_ID)

echo "=== Deployment Complete ==="
echo ""
echo "Frontend: $FRONTEND_URL"
echo "Backend:  $BACKEND_URL"
echo ""
echo "Visit the frontend URL in your browser to see the app!"
