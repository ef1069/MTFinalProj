# Cloud Shell Quick Start (Easiest Way)

This is the **fastest, easiest way** to deploy to Google Cloud. No local installs needed.

## Step 1: Open Cloud Shell

Go to https://console.cloud.google.com/cloudshell and sign in with your Google Cloud account. A terminal will open in your browser.

## Step 2: Clone the repo (or upload)

In Cloud Shell, clone your repo:

```bash
git clone https://github.com/your-username/MTFinalProj.git
cd MTFinalProj
```

Or if your repo is private, authenticate first:

```bash
gcloud auth login
git clone https://github.com/your-username/MTFinalProj.git
cd MTFinalProj
```

## Step 3: Set your Google Cloud Project

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
gcloud config set project $GCP_PROJECT_ID
```

Replace `your-gcp-project-id` with your actual GCP project ID (find it in the Cloud Console).

## Step 4: (Optional) Set MongoDB URI and JWT secret

If you have a MongoDB Atlas connection string and want to customize the JWT secret, set them as env vars:

```bash
export MONGO_URI="mongodb+srv://user:password@cluster.mongodb.net/bookclubs"
export JWT_SECRET="your-super-secret-jwt-key"
```

Otherwise, the script will use defaults (you can update them later in Cloud Run console).

## Step 5: Run the deploy script

```bash
bash gcp/deploy-cloud-shell.sh
```

This will:
1. Enable required Google Cloud APIs
2. Build and push your backend and frontend Docker images
3. Deploy backend to Cloud Run (private)
4. Deploy frontend to Cloud Run (public)

The script will print your frontend and backend URLs when done.

## Step 6: Access your app

Copy the **Frontend URL** from the output and visit it in your browser. You should see the MT Book Clubs app!

## To update and redeploy later

After making code changes:

```bash
cd MTFinalProj
git pull  # or git add . && git commit && git push
bash gcp/deploy-cloud-shell.sh
```

---

## Troubleshooting

**"gcloud: command not found"**
- You're not in Cloud Shell. Open https://console.cloud.google.com/cloudshell

**"PROJECT_NOT_SET"**
- Run: `gcloud config set project YOUR_PROJECT_ID`

**"Build failed"**
- Check Dockerfile paths. From repo root, run: `gcloud builds submit --config=cloudbuild.yaml`

**"Permission denied"**
- The Cloud Build service may need permissions. In GCP Console > IAM & Admin, grant `Cloud Run Admin` and `Service Account User` roles to your service account.

**"VITE_API_URL not resolving"**
- The backend URL is auto-populated after deploy. If the frontend can't reach the backend, check:
  - Backend deployed successfully (check Cloud Run console)
  - Frontend's `VITE_API_URL` env var matches the backend URL

---

## Next: Connect your Git repo to Cloud Build (auto-deploy on push)

Once deployed, you can set up continuous deployment:

1. Go to Cloud Build in GCP Console (https://console.cloud.google.com/cloud-build)
2. Click **Triggers** > **Connect repository**
3. Select your GitHub repo and authorize
4. Create a trigger that runs `cloudbuild.yaml` on push to `main`

Now every time you push to GitHub, Cloud Build will automatically build and deploy your app!
