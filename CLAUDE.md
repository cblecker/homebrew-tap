# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Homebrew tap containing utility formulas for various tools and utilities that don't qualify for homebrew-core. The repository contains Ruby formula files in the `Formula/` directory that define how to build and install various CLI tools.

## Common Commands

### Testing
- `brew test-bot --only-formulae --junit --only-json-tab --skip-dependents --testing-formulae=<formulae>` - Test specific formulae
- `brew style cblecker/tap --except-cops Layout/LineLength` - Check Ruby style with line length exemption
- `brew audit --tap cblecker/tap --skip-style --except specs` - Audit tap formulas

### Development
- Formula files are located in `Formula/` directory
- Each formula follows Homebrew Ruby DSL conventions
- Most formulas use Go + GoReleaser for building

## Architecture

### Formula Structure
- **Go-based tools**: Use `goreleaser` for building with `--clean --single-target` flags
- **Version handling**: Stable releases use specific git tags/revisions, head builds use snapshots
- **Completions**: Most formulas generate shell completions for bash/zsh/fish
- **Testing**: Include version checks and completion file verification

### Key Files
- `tap_migrations.json`: Maps old formula names to homebrew-core locations
- `formula_renames.json`: Currently empty, for future renames
- `test_exemptions.jq`: JQ script excluding specific formulas from CI testing
- `.github/workflows/tests.yml`: CI pipeline using brew test-bot

### CI Pipeline
The GitHub Actions workflow:
1. Runs on both Ubuntu and macOS
2. Uses Docker containers for Linux testing
3. Detects changed formulae automatically
4. Runs style checks, audits, and formula tests
5. Tests both individual formulae and dependents

### Formula Patterns
- Use `depends_on "go" => :build` and `depends_on "goreleaser" => :build` for Go-based tools
- Create bin directory: `bin.mkdir` or `mkdir bin`
- Build with goreleaser: `system "goreleaser", "build", *args, "--output=#{bin}/tool-name"`
- Generate completions: `generate_completions_from_executable()`
- Include git tree protection: `(buildpath/".git/info/exclude").append_lines ".brew_home"`

## Version Bumping Process

When bumping formula versions, follow this process:

1. **Find Latest Version**: 
   - For GitHub-hosted projects: Query GitHub releases API to get latest stable release
   - For other projects: List git tags to find latest version

2. **Get Revision SHA**:
   - The revision field must be the SHA of the HEAD commit of the tag (not the tag SHA itself)
   - Use `git ls-remote https://github.com/owner/repo.git refs/tags/<tag>^{}` to get the commit SHA for the tag

3. **Update Formula**:
   - Update the `tag:` field with the new version
   - Update the `revision:` field with the corresponding commit SHA

4. **Commit Changes**:
   - Create individual commits for each formula touched
   - Use commit message format: `<formula-name> <version>` (e.g., "osdctl 0.46.0")
   - Work directly on the main branch (no feature branches or PRs)
