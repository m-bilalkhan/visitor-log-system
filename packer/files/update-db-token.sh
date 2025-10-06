#!/bin/bash
set -e

ENV_FILE="/home/ec2-user/app/.env"
REGION="$(grep '^AWS_REGION=' "$ENV_FILE" | cut -d'=' -f2)"
DB_HOST=$(grep '^DB_HOST=' "$ENV_FILE" | cut -d'=' -f2)
DB_PORT=$(grep '^DB_PORT=' "$ENV_FILE" | cut -d'=' -f2)
DB_USER=$(grep '^DB_USER=' "$ENV_FILE" | cut -d'=' -f2)

if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ]; then
  DB_PASSWORD=$(aws rds generate-db-auth-token \
    --hostname "$DB_HOST" \
    --port "${DB_PORT:-5432}" \
    --region "$REGION" \
    --username "$DB_USER")

  # Remove old DB_PASSWORD and add new one
  sed -i '/^DB_PASSWORD=/d' "$ENV_FILE"
  echo "DB_PASSWORD=$DB_PASSWORD" >> "$ENV_FILE"

  chown ec2-user:ec2-user "$ENV_FILE"
  echo "[$(date)] Refreshed RDS IAM token."
fi
