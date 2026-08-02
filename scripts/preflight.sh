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

[[ -f .openai/hosting.json ]] && echo "FOUND: Codex Sites project" || echo "NOT FOUND: .openai/hosting.json"
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
