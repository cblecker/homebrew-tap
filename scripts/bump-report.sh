#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/bump-report.sh <formula-name> <old-tag> <old-revision> <new-tag> <new-revision>
# Prints a Markdown summary of upstream changes for the bump PR body: the
# compare link, who published the release, and changes to build and dependency
# files. Exits non-zero if the revisions can't be compared.
# Requires GH_TOKEN for the GitHub API.

if [[ ${#} -ne 5 ]]
then
  echo "Usage: ${0} <formula-name> <old-tag> <old-revision> <new-tag> <new-revision>" >&2
  exit 1
fi

FORMULA_NAME="${1}"
OLD_TAG="${2}"
OLD_REV="${3}"
NEW_TAG="${4}"
NEW_REV="${5}"

if [[ ! "${FORMULA_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]
then
  echo "Error: Invalid formula name '${FORMULA_NAME}'." >&2
  exit 1
fi

for rev in "${OLD_REV}" "${NEW_REV}"
do
  if [[ ! "${rev}" =~ ^[0-9a-f]{40}$ ]]
  then
    echo "Error: Invalid revision '${rev}'." >&2
    exit 1
  fi
done

REPO_URL=$(grep -E '^\s+url\s+"' "Formula/${FORMULA_NAME}.rb" | head -1 | sed -e 's/.*url.*"\(.*\)".*/\1/' -e 's/\.git$//')
if [[ ! "${REPO_URL}" =~ ^https://github\.com/([^/]+/[^/]+)$ ]]
then
  echo "Upstream '${REPO_URL}' is not on GitHub; no upstream report."
  exit 0
fi
REPO="${BASH_REMATCH[1]}"

# Fails (404) when either revision is missing or they have no common history
if ! STATUS=$(gh api "repos/${REPO}/compare/${OLD_REV}...${NEW_REV}" --jq '"\(.status), \(.ahead_by) ahead, \(.behind_by) behind"')
then
  echo "Error: Could not compare ${OLD_REV}...${NEW_REV} in ${REPO}." >&2
  exit 1
fi

# On failure gh api prints the error body to stdout, so only use output on success
release_author() {
  local author
  if author=$(gh api "repos/${REPO}/releases/tags/${1}" --jq '.author.login // "unknown"' 2>/dev/null)
  then
    echo "${author}"
  else
    echo "none"
  fi
}
OLD_AUTHOR=$(release_author "${OLD_TAG}")
NEW_AUTHOR=$(release_author "${NEW_TAG}")

echo "## Upstream changes"
echo
echo "- Compare (${STATUS}): https://github.com/${REPO}/compare/${OLD_REV}...${NEW_REV}"
echo "- \`${NEW_TAG}\` released by \`${NEW_AUTHOR}\`"
if [[ "${OLD_AUTHOR}" != "${NEW_AUTHOR}" ]]
then
  echo "- ⚠️ Publisher changed from \`${OLD_AUTHOR}\` (\`${OLD_TAG}\`) to \`${NEW_AUTHOR}\`"
fi

# The compare API lists at most 300 files, so diff a shallow, blob-less fetch
WORK=$(mktemp -d)
trap 'rm -rf "${WORK}"' EXIT
git -C "${WORK}" init -q
git -C "${WORK}" remote add origin "${REPO_URL}.git"
git -C "${WORK}" fetch -q --depth=1 --filter=blob:none origin "${OLD_REV}" "${NEW_REV}"

# Files that change what gets built or pulled in
BUILD_FILES=(
  ':(glob)**/uv.lock'
  ':(glob)**/pyproject.toml'
  ':(glob)**/requirements*.txt'
  ':(glob)**/setup.py'
  ':(glob)**/go.mod'
  ':(glob)**/go.sum'
  ':(glob)**/Cargo.lock'
  ':(glob)**/Cargo.toml'
  ':(glob)**/.goreleaser*'
)
CHANGED=$(git -C "${WORK}" diff --name-status "${OLD_REV}" "${NEW_REV}" -- "${BUILD_FILES[@]}")
if [[ -z "${CHANGED}" ]]
then
  exit 0
fi

echo
echo "### Build and dependency changes"
echo
echo '```'
echo "${CHANGED}"
echo '```'

# Pair each changed version line in uv.lock with its package name
LOCK_PATCH=$(git -C "${WORK}" diff --no-ext-diff --no-color "${OLD_REV}" "${NEW_REV}" -- ':(glob)**/uv.lock')
LOCK_CHANGES=$(echo "${LOCK_PATCH}" | awk '
  /^[ +-]name = "/ { split($0, a, "\""); name = a[2] }
  /^[+-]version = "/ { split($0, a, "\""); printf "- `%s` %s%s\n", name, substr($0, 1, 1), a[2] }
')
if [[ -n "${LOCK_CHANGES}" ]]
then
  echo
  echo "\`uv.lock\` version changes:"
  echo
  echo "${LOCK_CHANGES}"
fi
