#!/bin/bash
# bump-version.sh — update the harness version and date in VERSION
# Usage: ./bump-version.sh [new-version]
#        e.g.  ./bump-version.sh v2.2.0
#        If no version given, prompts interactively.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="${SCRIPT_DIR}/VERSION"

. "${VERSION_FILE}"

if [ -n "$1" ]; then
  new_version="$1"
else
  read -rp "New version (current: ${HARNESS_VERSION}): " new_version
fi

new_date="$(date +%Y-%m-%d)"

printf 'HARNESS_VERSION="%s"\nHARNESS_DATE="%s"\n' "${new_version}" "${new_date}" > "${VERSION_FILE}"

echo "VERSION updated: ${HARNESS_VERSION} → ${new_version} (${new_date})"
