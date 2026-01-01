#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

read -p " Enter App Directory [default: ./app]: " INPUT_DIR
APP_DIR=${INPUT_DIR:-"./app"}

read -p "Enter Image Name [default: my-app:local]: " INPUT_IMAGE
IMAGE_NAME=${INPUT_IMAGE:-"my-app:local"}

read -p "️ Enter K8s Namespace [default: dev-team-space]: " INPUT_NS
NAMESPACE=${INPUT_NS:-"dev-team-space"}

echo -e "${GREEN}Starting pipeline with config: ${NC}"
echo "Dir: $APP_DIR | Image: $IMAGE_NAME | Namespace: $NAMESPACE"
echo "----------------------------------------------------------"


echo "Step 1: Running Hadolint"
hadolint "$APP_DIR/Dockerfile"
if [ $? -ne 0 ]; then
    echo -e "${RED} Step 1 Failed: Dockerfile does not meet platform standards.${NC}"
    exit 1
fi
echo -e "${GREEN}Step 1 Passed!${NC}"

echo "Step 2: Building docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" "$APP_DIR"

echo "Step 3: Scanning for vulnerabilities with Trivy"
trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE_NAME"
echo -e "${GREEN} No High/Critical vulnerabilities found ${NC}"

echo "Step 4: Deploying to Minikube ($NAMESPACE)"
kubectl apply -f k8s/deployment.yaml -n "$NAMESPACE"

echo "Step 5: Injecting ${IMAGE_NAME} into deployment"
kubectl set image deployment/web-app auth-app-container="$IMAGE_NAME" -n "$NAMESPACE"


echo -e "${GREEN}Deployment Succesfull${NC}"
echo "Check with: kubectl get pods -n $NAMESPACE"


