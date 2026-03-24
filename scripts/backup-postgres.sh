#!/bin/bash

set -e

DATE=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="/opt/backups/postgres"
CONTAINER="lab-postgres"
USER="admin"

DBS=("career_upgrade_lab" "n8n")

mkdir -p "$BACKUP_DIR"

for DB in "${DBS[@]}"; do
  docker exec "$CONTAINER" pg_dump -U "$USER" -d "$DB" > "$BACKUP_DIR/${DB}_$DATE.sql"
  echo "Backup completed: $BACKUP_DIR/${DB}_$DATE.sql"
done
