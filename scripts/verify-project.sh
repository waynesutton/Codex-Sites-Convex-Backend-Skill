#!/usr/bin/env bash
set -u

project_dir="${1:-.}"
failures=0

check_file() {
  if [[ -e "$1" ]]; then
    echo "OK: $1"
  else
    echo "MISSING: $1"
    failures=$((failures + 1))
  fi
}

cd "$project_dir" 2>/dev/null || {
  echo "ERROR: cannot enter project directory: $project_dir"
  exit 2
}

check_file package.json
check_file .openai/hosting.json
check_file convex

if [[ -f package.json ]] && rg -q '"convex"[[:space:]]*:' package.json; then
  echo "OK: convex dependency"
else
  echo "MISSING: convex dependency"
  failures=$((failures + 1))
fi

if [[ -f package.json ]] && rg -q '@convex-dev/(self-)?static-hosting' package.json; then
  echo "FAILED: Convex static hosting is excluded; Codex Sites owns the frontend"
  failures=$((failures + 1))
else
  echo "OK: frontend hosting remains assigned to Codex Sites"
fi

if [[ -f convex/_generated/api.d.ts || -f convex/_generated/api.js ]]; then
  echo "OK: generated Convex API"
else
  echo "MISSING: generated Convex API; run npx convex codegen"
  failures=$((failures + 1))
fi

if rg -n --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!skills/**' --glob '!.codex/**' '(CONVEX_DEPLOY_KEY|CONVEX_ADMIN_KEY)[[:space:]]*=' .; then
  echo "WARNING: possible privileged Convex credential found; inspect before publishing"
else
  echo "OK: no obvious privileged Convex credential assignment in project files"
fi

if (( failures > 0 )); then
  echo "FAILED: $failures structural check(s) need attention"
  exit 1
fi

echo "PASSED: structural checks"
