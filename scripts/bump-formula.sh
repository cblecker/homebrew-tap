#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/bump-formula.sh <formula-name> <new-tag>
# Updates a Homebrew formula's tag and revision fields in-place.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <formula-name> <new-tag>" >&2
  exit 1
fi

FORMULA_NAME="$1"
NEW_TAG="$2"

# Validate inputs
if [[ ! "$FORMULA_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: Invalid formula name '${FORMULA_NAME}'." >&2
  exit 1
fi

if [[ ! "$NEW_TAG" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+([._-].*)?$ ]]; then
  echo "Error: Invalid tag format '${NEW_TAG}'." >&2
  exit 1
fi

FORMULA_FILE="Formula/${FORMULA_NAME}.rb"

if [[ ! -f "$FORMULA_FILE" ]]; then
  echo "Error: Formula file '${FORMULA_FILE}' not found." >&2
  exit 1
fi

# Verify the formula has tag: and revision: fields (skip head-only formulas)
if ! grep -q 'tag:' "$FORMULA_FILE"; then
  echo "Error: Formula '${FORMULA_NAME}' has no tag: field (head-only formula)." >&2
  exit 1
fi

if ! grep -q 'revision:' "$FORMULA_FILE"; then
  echo "Error: Formula '${FORMULA_NAME}' has no revision: field." >&2
  exit 1
fi

# Extract the git repo URL from the url line
REPO_URL=$(grep -E '^\s+url\s+"' "$FORMULA_FILE" | head -1 | sed -e 's/.*url.*"\(.*\)".*/\1/' -e 's/\.git$//')

if [[ -z "$REPO_URL" ]]; then
  echo "Error: Could not extract repository URL from '${FORMULA_FILE}'." >&2
  exit 1
fi

echo "Repository: ${REPO_URL}"
echo "New tag: ${NEW_TAG}"

# Get commit SHA via git ls-remote (single call for both annotated and lightweight tags)
# Prefer the dereferenced annotated tag (^{}) if present, otherwise use the lightweight tag
LS_OUTPUT=$(git ls-remote "${REPO_URL}.git" "refs/tags/${NEW_TAG}" "refs/tags/${NEW_TAG}^{}" 2>/dev/null)
NEW_SHA=$(echo "$LS_OUTPUT" | grep '\^{}' | awk '{print $1}' || true)
if [[ -z "$NEW_SHA" ]]; then
  NEW_SHA=$(echo "$LS_OUTPUT" | head -1 | awk '{print $1}')
fi

if [[ -z "$NEW_SHA" ]]; then
  echo "Error: Could not find tag '${NEW_TAG}' in repository '${REPO_URL}'." >&2
  exit 1
fi

echo "New SHA: ${NEW_SHA}"

# Update tag and revision fields (using temp file for BSD/GNU sed portability)
# Flexible whitespace match on input, normalized alignment on output
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
sed -e "s|tag: *\".*\"|tag:      \"${NEW_TAG}\"|" \
    -e "s|revision: *\".*\"|revision: \"${NEW_SHA}\"|" "$FORMULA_FILE" > "$tmp" && mv "$tmp" "$FORMULA_FILE"

# Verify the update
if ! grep -q "tag:      \"${NEW_TAG}\"" "$FORMULA_FILE"; then
  echo "Error: Failed to update tag in '${FORMULA_FILE}'." >&2
  exit 1
fi

if ! grep -q "revision: \"${NEW_SHA}\"" "$FORMULA_FILE"; then
  echo "Error: Failed to update revision in '${FORMULA_FILE}'." >&2
  exit 1
fi

echo "Successfully updated ${FORMULA_FILE}:"
echo "  tag:      \"${NEW_TAG}\""
echo "  revision: \"${NEW_SHA}\""
