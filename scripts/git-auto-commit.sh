#!/bin/bash

set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /opt/lab-infra

git add .

if ! git diff --cached --quiet; then
  git commit -m "auto: scheduled backup of repo state"
  git push
else
  echo "No changes to commit"
fi
