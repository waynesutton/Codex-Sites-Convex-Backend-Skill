#!/usr/bin/env bash
set -u

project_dir="${1:-.}"
env_file="$project_dir/.env.local"
failures=0

if [[ ! -d "$project_dir" ]]; then
  echo "ERROR: project directory does not exist: $project_dir"
  exit 2
fi

if [[ ! -f "$env_file" ]]; then
  echo "MISSING: .env.local"
  failures=$((failures + 1))
elif rg -q '^NEXT_PUBLIC_CONVEX_URL=.+$' "$env_file"; then
  echo "OK: NEXT_PUBLIC_CONVEX_URL is configured"
else
  echo "MISSING: nonempty NEXT_PUBLIC_CONVEX_URL in .env.local"
  failures=$((failures + 1))
fi

if [[ -f "$env_file" ]] && rg -q '^CONVEX_AGENT_MODE=anonymous$' "$env_file"; then
  echo "FAILED: remove legacy CONVEX_AGENT_MODE=anonymous; use npx convex dev --once"
  failures=$((failures + 1))
fi

if [[ -f "$project_dir/convex/_generated/api.d.ts" || -f "$project_dir/convex/_generated/api.js" ]]; then
  echo "OK: generated Convex API exists"
else
  echo "MISSING: generated Convex API"
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  echo "NOT READY: provision Convex before starting Sites or opening the browser"
  exit 1
fi

echo "READY: Convex backend configuration exists; Sites may start"
