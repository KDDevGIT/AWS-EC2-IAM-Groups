#!/bin/bash
set -euxo pipefail

# Make sure SSM + CLI are good to go (AL2023 has both, but update to be safe)
dnf -y update

# Prove role-based access (no keys) on first boot
BUCKET_NAME="${bucket_name}"

# Wait for instance profile credentials to be available
for i in {1..30}; do
  if aws sts get-caller-identity >/var/log/role-identity.json 2>/var/log/role-identity.err; then
    break
  fi
  sleep 5
done

echo "Hello from $(hostname) at $(date)" >/tmp/hello.txt
aws s3 cp /tmp/hello.txt "s3://${BUCKET_NAME}/proof/hello.txt"
