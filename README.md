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

Notes and next steps
- Add more API endpoints (memberships, meetings, books CRUD).
- Add authorization middleware and protect routes.
- Add tests, CI, and production secrets (don't store secrets in docker-compose).
- For GCP deployment: push backend and frontend images to Container Registry or Artifact Registry and deploy to Cloud Run, or deploy using GKE with Kubernetes manifests.
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
