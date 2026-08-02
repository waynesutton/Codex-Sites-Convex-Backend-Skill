#!/usr/bin/env bash
set -u

query="${*:-}"
catalog_url="https://www.convex.dev/components/get-convex.md"
catalog_file="$(mktemp -t convex-components.XXXXXX)"
trap 'rm -f "$catalog_file"' EXIT

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required to refresh the official component catalog"
  exit 2
fi
if ! curl -L -sS "$catalog_url" -o "$catalog_file"; then
  echo "ERROR: could not fetch $catalog_url"
  exit 1
fi

# Remove the excluded frontend-hosting entry before displaying candidates.
filtered_catalog="$(awk '
  /^### \[Static-Hosting\]/ { excluded = 1; next }
  excluded && /^## / { excluded = 0 }
  !excluded { print }
' "$catalog_file")"

echo "SOURCE: $catalog_url"

if [[ -z "$query" ]]; then
  printf '%s\n' "$filtered_catalog" | rg '^## |^### '
  exit 0
fi

if ! printf '%s\n' "$filtered_catalog" | rg -i -C 7 -- "$query"; then
  echo "NO MATCH: $query"
  echo "Use built-in Convex docs or refine the capability keywords."
fi
