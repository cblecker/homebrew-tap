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

## Slash Commands

### `/bump [formula-name]`

Bump Homebrew formula versions to their latest releases.

- `/bump` - Bump all formulas that need updating (automatically detected via `brew livecheck`)
- `/bump <formula-name>` - Bump a specific formula to its latest version

The command automatically:
1. Finds the latest version from GitHub releases or git tags
2. Gets the correct commit SHA for the tag
3. Updates the formula's `tag:` and `revision:` fields
4. Creates properly formatted commits on the main branch