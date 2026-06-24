#!/usr/bin/env bash
# Deploys DR first, then primary.
# Run from anywhere: bash terraform/up.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "==> Deploying DR (eu-central-1)..."
cd "$ROOT/environments/dr"
terraform init -input=false
terraform apply -input=false -auto-approve

echo ""
echo "==> Deploying Primary (eu-west-1)..."
cd "$ROOT/environments/primary"
terraform init -input=false
terraform apply -input=false -auto-approve

echo ""
echo "==> Done. Primary outputs:"
terraform output
