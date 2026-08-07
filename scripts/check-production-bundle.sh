#!/usr/bin/env bash
set -u

bundle_dir="${1:-}"
production_url="${2:-}"
development_url="${3:-}"
failures=0

if [[ -z "$bundle_dir" || ! -d "$bundle_dir" ]]; then
  echo "ERROR: provide the finished bundle directory"
  exit 2
fi
if [[ -z "$production_url" ]]; then
  echo "ERROR: provide the exact production Convex URL"
  exit 2
fi
if ! command -v rg >/dev/null 2>&1; then
  echo "ERROR: ripgrep (rg) is required to scan the production bundle"
  exit 2
fi

if rg -n -I -g '*' '(localhost|127\.0\.0\.1|CONVEX_DEPLOY_KEY|CONVEX_ADMIN_KEY)' "$bundle_dir"; then
  echo "FAILED: bundle contains localhost or privileged Convex credential markers"
  failures=$((failures + 1))
else
  echo "OK: no localhost or privileged Convex credential markers"
fi

if [[ -n "$development_url" ]] && rg -n -I -F -- "$development_url" "$bundle_dir"; then
  echo "FAILED: bundle contains the development Convex URL"
  failures=$((failures + 1))
else
  echo "OK: development Convex URL is absent"
fi

if rg -q -I -F -- "$production_url" "$bundle_dir"; then
  echo "OK: exact production Convex URL is present"
else
  echo "FAILED: exact production Convex URL is not present"
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  echo "FAILED: production bundle is not safe to publish"
  exit 1
fi

echo "PASSED: production bundle targets the intended Convex deployment"
