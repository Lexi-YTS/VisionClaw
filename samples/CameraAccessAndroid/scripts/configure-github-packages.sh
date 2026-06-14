#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
local_properties="$project_dir/local.properties"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required. Install GitHub CLI or add github_token manually to local.properties." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

scopes="$(gh auth status 2>&1 | sed -n "s/.*Token scopes: '\\(.*\\)'.*/\\1/p" | tr -d " '")"
if [[ ",$scopes," != *",read:packages,"* ]]; then
  echo "gh token is missing read:packages. Run: gh auth refresh -s read:packages" >&2
  exit 1
fi

token="$(gh auth token)"
if [[ -z "$token" ]]; then
  echo "gh auth token returned an empty value." >&2
  exit 1
fi

touch "$local_properties"
chmod 600 "$local_properties"

if grep -q '^github_token=' "$local_properties"; then
  GITHUB_TOKEN_VALUE="$token" perl -0pi -e 's/^github_token=.*$/github_token=$ENV{GITHUB_TOKEN_VALUE}/m' "$local_properties"
else
  printf '\ngithub_token=%s\n' "$token" >> "$local_properties"
fi

echo "Wrote github_token to local.properties without printing it."
echo "Gradle can now resolve Meta DAT artifacts from GitHub Packages."
