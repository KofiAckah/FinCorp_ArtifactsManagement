#!/bin/bash
# DR failover: restore the cross-region snapshot in eu-central-1 and time it.
# Success criterion: restored DB reaches "available" in under 30 minutes.
set -euo pipefail

DR_REGION="eu-central-1"
RESTORED_ID="fincorp-dr-restored"
SUBNET_GROUP="fincorp-dr-restore-subnet-group"
INSTANCE_CLASS="db.t3.micro"

# Most recent COMPLETED recovery point copied into the DR vault.
SNAPSHOT_ARN=$(aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name fincorp-dr-vault \
  --region "$DR_REGION" \
  --query 'reverse(sort_by(RecoveryPoints[?Status==`COMPLETED`], &CreationDate))[0].RecoveryPointArn' \
  --output text)

if [ -z "$SNAPSHOT_ARN" ] || [ "$SNAPSHOT_ARN" = "None" ]; then
  echo "ERROR: no COMPLETED recovery point found in fincorp-dr-vault."
  exit 1
fi

START_EPOCH=$(date +%s)
echo "=========================================================="
echo "DR FAILOVER START: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "Restoring from: $SNAPSHOT_ARN"
echo "=========================================================="

aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier "$RESTORED_ID" \
  --db-snapshot-identifier "$SNAPSHOT_ARN" \
  --db-instance-class "$INSTANCE_CLASS" \
  --db-subnet-group-name "$SUBNET_GROUP" \
  --no-multi-az \
  --no-publicly-accessible \
  --region "$DR_REGION" \
  --query 'DBInstance.DBInstanceStatus' --output text

echo "Restore initiated. Polling until 'available'..."
while true; do
  STATUS=$(aws rds describe-db-instances \
    --db-instance-identifier "$RESTORED_ID" \
    --region "$DR_REGION" \
    --query 'DBInstances[0].DBInstanceStatus' --output text)
  ELAPSED=$(( ($(date +%s) - START_EPOCH) / 60 ))
  echo "[$ELAPSED min] status: $STATUS"
  [ "$STATUS" = "available" ] && break
  sleep 30
done

END_EPOCH=$(date +%s)
TOTAL_MIN=$(( (END_EPOCH - START_EPOCH) / 60 ))
TOTAL_SEC=$(( (END_EPOCH - START_EPOCH) % 60 ))
ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier "$RESTORED_ID" \
  --region "$DR_REGION" \
  --query 'DBInstances[0].Endpoint.Address' --output text)

echo "=========================================================="
echo "DR FAILOVER COMPLETE: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "Recovery time: ${TOTAL_MIN}m ${TOTAL_SEC}s"
echo "Restored endpoint: $ENDPOINT"
if [ "$TOTAL_MIN" -lt 30 ]; then
  echo "RESULT: PASS — recovery under 30-minute target."
else
  echo "RESULT: FAIL — recovery exceeded 30-minute target."
fi
echo "=========================================================="
