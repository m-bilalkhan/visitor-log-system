#!/bin/bash
set -e
PROJECT_NAME=$(grep '^PROJECT_NAME=' /home/ec2-user/app/.env | cut -d '=' -f2)
ENV=$(grep '^ENV=' /home/ec2-user/app/.env | cut -d '=' -f2)
ENV_PATH="/${PROJECT_NAME}/${ENV}"
REGION=$(grep '^AWS_REGION=' /home/ec2-user/app/.env | cut -d '=' -f2)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ENV_FILE="/home/ec2-user/app/.env"

#-------------------------------------
# 1. AWS Configuration
#-------------------------------------
aws configure set region "$REGION"

# -------------------------------------
# 2. Fetch parameters from SSM
# -------------------------------------
PARAMS=$(aws ssm get-parameters-by-path \
  --path "$ENV_PATH" \
  --with-decryption \
  --query "Parameters[*].{Name:Name,Value:Value}" \
  --output text)

# -------------------------------------
# 3. Write parameters to .env file
# -------------------------------------
echo "$PARAMS" | while read Name Value; do
  Key=$(basename "$Name")
  UpperKey="${Key^^}"
  
  # Remove any existing line starting with KEY= (case-insensitive)
  sed -i "/^${UpperKey}=/Id" "$ENV_FILE"
  
  # Add the new key=value line
  echo "${UpperKey}=$Value" >> "$ENV_FILE"
done

# -------------------------------------
# 4. ECR Login  
# -------------------------------------
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
