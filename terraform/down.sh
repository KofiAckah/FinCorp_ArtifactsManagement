#!/usr/bin/env bash
# Destroys primary first, then DR.
# Run from anywhere: bash terraform/down.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

read -r -p "This will destroy ALL resources. Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 0
fi

echo "==> Destroying Primary (eu-west-1)..."
cd "$ROOT/environments/primary"
terraform destroy -auto-approve

echo ""
echo "==> Destroying DR (eu-central-1)..."
cd "$ROOT/environments/dr"
terraform destroy -auto-approve

echo ""
echo "==> All resources destroyed."
