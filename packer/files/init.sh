#!/bin/bash
set -e
PROJECT_NAME=$(grep '^PROJECT_NAME=' /home/ec2-user/app/.env | cut -d '=' -f2)
ENV=$(grep '^ENV=' /home/ec2-user/app/.env | cut -d '=' -f2)
ENV_PATH="/${PROJECT_NAME}/${ENV}"
REGION="$(aws configure get region)"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ENV_FILE="/home/ec2-user/app/.env"

# -------------------------------------
# 1. Fetch parameters from SSM
# -------------------------------------
PARAMS=$(aws ssm get-parameters-by-path \
  --path "$ENV_PATH" \
  --with-decryption \
  --query "Parameters[*].{Name:Name,Value:Value}" \
  --output text)

# -------------------------------------
# 2. Write parameters to .env file
# -------------------------------------
echo "$PARAMS" | while read Name Value; do
  Key=$(basename "$Name")
  echo "${Key^^}=$Value" >> "$ENV_FILE"
done

# -------------------------------------
# 3. ECR Login  
# -------------------------------------
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
