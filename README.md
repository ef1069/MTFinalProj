# MT Book Clubs — Minimal Scaffold

This repository contains a minimal foundation for an online book clubs app using Node.js, React (Vite), MongoDB, Docker, and instructions for deploying to Google Cloud.

What's included
- backend/: Express + Mongoose API (auth, clubs)
- frontend/: Vite + React app (minimal pages)
- docker-compose.yml: runs MongoDB, backend, frontend for local development

Quick local run (requires Docker)

1) Build and start everything:

```powershell
docker-compose up --build
```

2) Open the frontend at http://localhost:3000 (served by nginx). The backend API runs at http://localhost:5000

GCP Deployment
See [`gcp/DEPLOYMENT.md`](gcp/DEPLOYMENT.md) for full instructions on deploying to Google Cloud:
- **Cloud Run** (serverless, recommended for quick start)
- **GKE** (Kubernetes, for production scale)

Includes scripts, manifests, and step-by-step guides.

Notes and next steps
- Add more API endpoints (memberships, meetings, books CRUD).
- Add authorization middleware and protect routes.
- Add tests, CI, and production secrets (don't store secrets in docker-compose).
- Update MongoDB URI to use MongoDB Atlas for production.
- Enable Cloud Build CI/CD to auto-deploy on git push.
# MTFinalProj
Final project for Modern Technologies
## Introduction
This is a book club app that allows users to communicate and share thoughts about books, authors, genres, and much more. The goal is to create communities and positive environments to share interests and thoughts.
## Technology Stack
**Frontend**: React
**Backend**: Node.js
**AI Integration**: Open AI, GitHub CoPilot
**Deployment**: Docker, Google Cloud
## Getting Started
Clone repository:
Install dependencies: 'npm install'
Set up environment variables:
Start the app: 'npm run dev'
