#!/usr/bin/env bash
set -u

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$repo_dir/tests/fixtures/registered-public-unpublished.json"

if ! command -v rg >/dev/null 2>&1; then
  echo "FAILED: ripgrep (rg) is required for this regression test"
  exit 2
fi

set +e
output="$($repo_dir/scripts/check-publication-state.sh "$fixture" 2>&1)"
status=$?
set -e

if [[ "$status" -ne 1 ]]; then
  echo "FAILED: expected unpublished recovery status 1, received $status"
  printf '%s\n' "$output"
  exit 1
fi

required_patterns=(
  "SITE REGISTRATION: CONFIRMED"
  "ACCESS POLICY: PUBLIC"
  "ACCESS ACTION: preserve public"
  "PUBLICATION STATE: UNPUBLISHED"
  "LATEST SAVED VERSION: 0"
  "SITES NEXT_PUBLIC_CONVEX_URL: MISSING"
  "FRONTEND BACKEND: ACCOUNTLESS LOCAL OR LOCALHOST"
  "obtain fresh deployment consent"
  "Set NEXT_PUBLIC_CONVEX_URL in Sites as non-secret public configuration"
  "Push the exact validated source commit"
  "require get_site.current_live_url"
)

for pattern in "${required_patterns[@]}"; do
  if ! rg -F -q -- "$pattern" <<<"$output"; then
    echo "FAILED: missing expected recovery instruction: $pattern"
    printf '%s\n' "$output"
    exit 1
  fi
done

echo "PASSED: registered public unpublished recovery state"
