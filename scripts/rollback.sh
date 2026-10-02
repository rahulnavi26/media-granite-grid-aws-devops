#!/usr/bin/env bash
# Rolls back any in-flight instance refresh. Usage: rollback.sh <asg-name-prefix>  (e.g. media-prod)
set -euo pipefail
PREFIX="$1"
for ASG in $(aws autoscaling describe-auto-scaling-groups \
    --query "AutoScalingGroups[?starts_with(AutoScalingGroupName, '$PREFIX-')].AutoScalingGroupName" \
    --output text); do
  STATUS=$(aws autoscaling describe-instance-refreshes --auto-scaling-group-name "$ASG" \
    --max-records 1 --query 'InstanceRefreshes[0].Status' --output text)
  if [[ "$STATUS" == "InProgress" || "$STATUS" == "Pending" ]]; then
    echo "Rolling back in-flight refresh on $ASG"
    aws autoscaling rollback-instance-refresh --auto-scaling-group-name "$ASG"
  else
    echo "$ASG refresh status is $STATUS - nothing in flight"
  fi
done
echo "If the refresh had already succeeded, redeploy the last prod-released build:"
echo "Pipelines > Runs > (last good run) > Deploy (prod) > Rerun stage."
