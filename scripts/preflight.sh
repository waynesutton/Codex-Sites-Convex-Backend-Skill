#!/usr/bin/env bash
set -u

project_dir="${1:-.}"

if [[ ! -d "$project_dir" ]]; then
  echo "ERROR: project directory does not exist: $project_dir"
  exit 2
fi

cd "$project_dir" || exit 2

missing=0
for command_name in node npm npx; do
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "OK: $command_name"
  else
    echo "MISSING: $command_name"
    missing=1
  fi
done

if [[ ! -f .openai/hosting.json ]]; then
  echo "LOCAL SITES PROJECT: NOT FOUND: .openai/hosting.json"
  echo "SITES REGISTRATION: NOT REGISTERED: no hosting manifest"
elif ! command -v node >/dev/null 2>&1; then
  echo "LOCAL SITES PROJECT: FOUND: .openai/hosting.json"
  echo "SITES REGISTRATION: UNKNOWN: node is required to validate project_id"
else
  registration_output="$(node -e '
    const fs = require("node:fs");
    try {
      const hosting = JSON.parse(fs.readFileSync(".openai/hosting.json", "utf8"));
      if (typeof hosting.project_id === "string" && hosting.project_id.trim() !== "") {
        console.log(hosting.project_id.trim());
        process.exit(0);
      }
      process.exit(1);
    } catch {
      process.exit(2);
    }
  ')"
  registration_status=$?

  if [[ "$registration_status" -eq 0 ]]; then
    echo "LOCAL SITES PROJECT: FOUND: .openai/hosting.json"
    echo "SITES REGISTRATION: LINKED LOCALLY: call get_site to confirm the hosted record"
    echo "SIDEBAR VISIBILITY: REMOTE UI CHECK REQUIRED: get_site does not prove list indexing"
  elif [[ "$registration_status" -eq 1 ]]; then
    echo "LOCAL SITES PROJECT: FOUND: .openai/hosting.json"
    echo "SITES REGISTRATION: NOT REGISTERED: valid project_id is missing"
  else
    echo "LOCAL SITES PROJECT: INVALID: .openai/hosting.json is not valid JSON"
    echo "SITES REGISTRATION: UNKNOWN: fix the hosting manifest first"
  fi
fi
echo "SAVED SITES VERSION: REMOTE CHECK REQUIRED: local files do not prove a saved version"
echo "PUBLISHED SITE: REMOTE CHECK REQUIRED: require get_site.current_live_url"
[[ -f package.json ]] && echo "FOUND: package.json" || echo "NOT FOUND: package.json"
[[ -d convex ]] && echo "FOUND: convex backend" || echo "NOT FOUND: convex/"
[[ -f convex/_generated/api.d.ts || -f convex/_generated/api.js ]] && echo "FOUND: generated Convex API" || echo "NOT FOUND: generated Convex API"
[[ -f AGENTS.md ]] && echo "FOUND: AGENTS.md" || echo "NOT FOUND: AGENTS.md"
if [[ -f .env.local ]] && rg -q '^NEXT_PUBLIC_CONVEX_URL=.+$' .env.local; then
  echo "FOUND: NEXT_PUBLIC_CONVEX_URL"
else
  echo "NOT FOUND: NEXT_PUBLIC_CONVEX_URL"
fi

if [[ -f package-lock.json ]]; then
  echo "PACKAGE MANAGER: npm"
elif [[ -f bun.lock || -f bun.lockb ]]; then
  echo "PACKAGE MANAGER: bun"
elif [[ -f pnpm-lock.yaml ]]; then
  echo "PACKAGE MANAGER: pnpm"
elif [[ -f yarn.lock ]]; then
  echo "PACKAGE MANAGER: yarn"
else
  echo "PACKAGE MANAGER: not established"
fi

exit "$missing"
