---
description: Bump Homebrew formula versions
allowed-tools: Bash(brew livecheck:*), Bash(git ls-remote:*), Bash(git add:*), Bash(git commit:*), Read, Edit, Grep, Glob, mcp__github__list_releases
argument-hint: "[formula-name]"
---

# Bump Formula Versions

This command bumps Homebrew formula versions to their latest releases.

## Usage

- `/bump` - Bump all formulas that need updating (using `brew livecheck`)
- `/bump <formula-name>` - Bump a specific formula

## Instructions

Follow the version bumping process:

### Step 1: Determine which formulas to bump

**If no argument provided:**
- Run `brew livecheck --tap=cblecker/tap --newer-only --quiet` with `dangerouslyDisableSandbox: true` to list formulas needing updates
- **IMPORTANT**: If the brew livecheck command fails, abort the operation and inform the user that livecheck failed
- Process each formula found

**If formula argument provided:**
- Process only the specified formula: `$ARGUMENTS`

### Step 2: For each formula to update

1. **Read the formula file** at `Formula/<formula-name>.rb`

2. **Extract the repository URL** from the `url` field in the formula

3. **Find the latest version:**
   - For GitHub-hosted projects: Use the GitHub MCP server to query releases API to get latest stable release
   - For other projects: Use git tags to find latest version

4. **Get the commit SHA for the tag:**
   - The revision field must be the SHA of the HEAD commit of the tag (not the tag SHA itself)
   - Use: `git ls-remote <repo-url> refs/tags/<tag>^{}`
   - Extract the commit SHA from the output

5. **Update the formula file:**
   - Update the `tag:` field with the new version (include the `v` prefix if the tag has it)
   - Update the `revision:` field with the commit SHA

6. **Create a commit:**
   - Stage the formula file: `git add Formula/<formula-name>.rb`
   - Create commit with format: `<formula-name> <version>` (without the `v` prefix)
   - Example: "osdctl 0.50.1" for tag "v0.50.1"

### Step 3: Complete

Work directly on the main branch. Do not create feature branches or pull requests.

## Important Notes

- Create individual commits for each formula touched
- The revision field is the commit SHA, not the tag SHA
- Remove the `v` prefix from version in commit messages
- Work directly on the main branch
