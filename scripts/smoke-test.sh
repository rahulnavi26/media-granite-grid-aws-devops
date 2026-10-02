#!/usr/bin/env bash
# Post-deployment checks. Usage: smoke-test.sh <base-url> <expected-image-tag>
set -euo pipefail
BASE="$1"; EXPECTED="$2"

for path in /publishing/healthz /streaming/healthz; do
  for i in $(seq 1 10); do
    CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$path" || true)
    [[ "$CODE" == "200" ]] && { echo "$path -> 200"; break; }
    echo "$path -> $CODE (attempt $i)"; sleep 6
    [[ $i -eq 10 ]] && { echo "##vso[task.logissue type=error]$path unhealthy"; exit 1; }
  done
done

# Prove the new build is the one actually serving traffic
for svc in publishing streaming; do
  GOT=$(curl -sf "$BASE/$svc/version" | jq -r .imageTag)
  [[ "$GOT" == "$EXPECTED" ]] || {
    echo "##vso[task.logissue type=error]$svc serves $GOT, expected $EXPECTED"; exit 1; }
done
echo "Smoke tests passed for $EXPECTED"
