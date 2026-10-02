#!/usr/bin/env bash
# Waits for ASG instance refreshes to finish. Usage: wait-instance-refresh.sh <asg-name> [<asg-name> ...]
set -euo pipefail
for ASG in "$@"; do
  STATUS="Pending"
  for i in $(seq 1 60); do   # up to 30 minutes per ASG
    STATUS=$(aws autoscaling describe-instance-refreshes \
      --auto-scaling-group-name "$ASG" --max-records 1 \
      --query 'InstanceRefreshes[0].Status' --output text)
    PCT=$(aws autoscaling describe-instance-refreshes \
      --auto-scaling-group-name "$ASG" --max-records 1 \
      --query 'InstanceRefreshes[0].PercentageComplete' --output text)
    echo "[$i] $ASG: $STATUS ($PCT%)"
    case "$STATUS" in
      Successful|None) break ;;
      Failed|Cancelled|RollbackSuccessful|RollbackFailed)
        echo "##vso[task.logissue type=error]$ASG refresh ended: $STATUS"; exit 1 ;;
    esac
    sleep 30
  done
  [[ "$STATUS" == "Successful" || "$STATUS" == "None" ]] || {
    echo "##vso[task.logissue type=error]$ASG refresh timed out ($STATUS)"; exit 1; }
done
