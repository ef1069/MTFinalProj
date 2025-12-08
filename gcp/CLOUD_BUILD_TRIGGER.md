# Cloud Build Trigger Setup Guide

This guide explains how to set up a **Cloud Build trigger** so your app auto-deploys to Cloud Run whenever you push code to GitHub.

## Prerequisites

- GCP Project with billing enabled
- GitHub account with your MTFinalProj repository
- `cloudbuild.yaml` in your repo root (already included)

## Step 1: Connect GitHub Repository to Cloud Build

1. Go to **Cloud Build** in GCP Console: https://console.cloud.google.com/cloud-build/builds
2. Click **Triggers** in the left menu
3. Click **Create Trigger**
4. Select **GitHub** as the source
5. Click **Authenticate with GitHub** (if prompted)
   - Authorize `gcloud` to access your GitHub account
   - You may need to grant repository access
6. Select your GitHub repository (`ef1069/MTFinalProj`)
7. Click **Connect Repository**

## Step 2: Configure the Trigger

After connecting your repo:

1. Set **Trigger name**: `mt-bookclubs-auto-deploy`
2. Set **Event**: Select **Push to a branch**
3. Set **Branch**: Enter `^main$` (deploys on push to main branch)
4. Set **Build configuration**: Select **Cloud Build configuration file (yaml)**
5. Set **Cloud Build configuration file location**: `cloudbuild.yaml`
6. Expand **Substitutions** section and add these variables:

   | Variable | Value |
   |----------|-------|
   | `_MONGO_URI` | Your MongoDB Atlas connection string (e.g., `mongodb+srv://user:pass@cluster.mongodb.net/bookclubs`) |
   | `_JWT_SECRET` | Your JWT secret key (use a strong random string) |
   | `_REGION` | `us-central1` (or your preferred Cloud Run region) |

7. Click **Create** to finish

## Step 3: Grant Cloud Build Required Permissions

Cloud Build needs permissions to deploy to Cloud Run. Add IAM roles:

1. Go to **IAM & Admin** > **Service Accounts**: https://console.cloud.google.com/iam-admin/serviceaccounts
2. Find the service account named `{PROJECT_NUMBER}@cloudbuild.gserviceaccount.com`
3. Click on it to open details
4. Go to the **Roles** tab
5. Click **Grant Access**
6. Add these roles:
   - **Cloud Run Admin** (to deploy services)
   - **Service Account User** (to use service accounts)
   - **Storage Admin** (to access build artifacts)

Alternatively, use `gcloud` in Cloud Shell:

```bash
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/run.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/storage.admin
```

## Step 4: Test the Trigger

Make a small change to your repo and push it to the `main` branch:

```bash
git add .
git commit -m "Test Cloud Build trigger"
git push origin main
```

Go to **Cloud Build** > **Builds** and check if a build started. You should see:
1. Build logs showing Docker build steps
2. Backend deployed to Cloud Run
3. Frontend deployed to Cloud Run

Once the build completes, you'll see the service URLs printed in the build logs.

## Step 5: View Deployment

After a successful build:

1. Go to **Cloud Run**: https://console.cloud.google.com/run
2. You should see two services:
   - `mt-bookclubs-backend` (private, no public access)
   - `mt-bookclubs-frontend` (public)
3. Click `mt-bookclubs-frontend` to get the public URL
4. Visit the URL in your browser to see your app!

## Monitoring & Logs

To view build logs:

```bash
gcloud builds log {BUILD_ID} --stream
```

To view Cloud Run service logs:

```bash
gcloud run services logs read mt-bookclubs-backend --region us-central1
gcloud run services logs read mt-bookclubs-frontend --region us-central1
```

## Troubleshooting

**Build fails with "gcloud: command not found"**
- The Cloud Build image is using an old version. The fix is in `cloudbuild.yaml` (already applied).

**"Permission denied" when deploying**
- Check that the Cloud Build service account has the required IAM roles (see Step 3).

**Frontend can't reach backend**
- The backend URL is hardcoded in `cloudbuild.yaml` substitutions. For dynamic URLs, use Cloud Run internal services or update the substitution value after first deployment.

**Build takes too long**
- Consider using a faster machine type or caching Docker layers.

## Next Steps

- **Add custom domain**: Go to Cloud Run service > **Manage Custom Domains** and add your domain
- **Set up CI/CD for staging**: Create another trigger on the `develop` branch deploying to separate staging services
- **Add automated tests**: Extend `cloudbuild.yaml` to run tests before building Docker images
- **Monitor with Google Cloud Monitoring**: Set up alerts for errors and high latency

## Reference

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Build Triggers](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers)
- [Cloud Run Deployment](https://cloud.google.com/run/docs/deploying)
