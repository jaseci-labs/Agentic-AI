gcloud auth login
PROJECT_ID=fourth-cirrus-467916-j9
REGION=asia-south1
REPO=jac-repo
SERVICE=jac-gpt
IMAGE=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${SERVICE}:$(date +%Y%m%d-%H%M)

gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com

gcloud artifacts repositories create ${REPO} \
  --repository-format=docker \
  --location=${REGION} \
  --description="jac-gpt images"

gcloud builds submit server --tag ${IMAGE}

gcloud run deploy ${SERVICE} \
  --image ${IMAGE} \
  --region ${REGION} \
  --platform managed \
  --allow-unauthenticated \
  --port 8080 \
  --cpu 1 \
  --memory 512Mi \
  --max-instances 10


gcloud run services update ${SERVICE} \
  --region ${REGION} \
  --update-env-vars="DATABASE_HOST=,OPENAI_API_KEY=,PYTHONUNBUFFERED=1"
