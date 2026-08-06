## Problem Statement

There is no way to visually review the diff of files being modified by Claude (or manually) without running `git diff` repeatedly. The user wants a live, interactive TUI that shows all dirty file diffs side-by-side, updates automatically as files change, and supports inline commenting for feedback loops.

## Solution

Install Hunk (a review-first terminal diff viewer) and integrate it into the existing `git-file-*` toolchain as `git-file-watch` / `vfw`. The tool runs in a separate terminal and shows a live, auto-refreshing split diff of all tracked dirty files. No Claude integration, no Kitty tab bar integration — just a standalone command.

## User Stories

1. As a developer, I want to run `vfw` in a terminal to see a live diff of all dirty tracked files so that I can review changes as they happen.
2. As a developer, I want the diff to auto-refresh when files change so that I do not need to re-run any command.
3. As a developer, I want a split (side-by-side) layout so that I can compare old and new code easily.
4. As a developer, I want only tracked file changes shown (no untracked files) so that the view matches what `vfe` shows.
5. As a developer, I want to toggle between split and stacked layout so that I can adapt to narrow terminals.
6. As a developer, I want to leave inline comments on the diff so that I can later feed those comments back to Claude.
7. As a developer, I want line numbers visible so that I can reference specific lines.
8. As a developer, I want the TUI background to be transparent so that it matches my terminal theme.
9. As a developer, I want hunk installed via the existing yarn/package.json system so that versioning is consistent with other tools.
10. As a developer, I want hunk config managed in oroshi and deployed via symlink so that it is reproducible across machines.

## Implementation Decisions

### Installation via package.json

`hunkdiff` is added to `package.json` dependencies, same as `claude-code`, `eslint_d`, etc. The binary is available at `$OROSHI_ROOT/node_modules/.bin/hunk` and on PATH via the existing bin path setup.

### Deploy script

`tools/git/hunk/deploy` symlinks the config file to `~/.config/hunk/config.toml`. No install script — yarn handles the binary. No `generate-config` — the config is static for now (custom theme with build pipeline is a future task).

### Config

Minimal `config.toml`:
- `mode = "split"` — side-by-side layout
- `watch = true` — auto-refresh on filesystem changes
- `line_numbers = true`
- `transparent_background = true` — inherit terminal background
- `exclude_untracked = true` — match `vfe` behavior (tracked dirty files only)

### git-file-watch

A trivial ZSH autoload function in the `git/file` family. Launches `hunk diff --watch` from the git root. No arguments, no filtering — Hunk handles everything.

### Alias

`vfw` alias added to `tools/term/zsh/config/aliases/git/file.zsh`, following the existing `vft`/`vfl`/`vfe` pattern.

## Testing Decisions

No tests. Every artifact is either a static config file, a one-line alias, or a trivial wrapper function. Testing these would be noise.

## Out of Scope

- Custom Hunk theme with color build pipeline (future task — uses same pattern as git/rg config generation)
- Claude Code skill for reading Hunk comments (future task — phase 2 after validating the basic workflow)
- ZSH wrapper commands for `hunk session` CLI (future task — naming TBD after phase 1 validation)
- Kitty tab bar integration or auto-launch hooks
- Neovim integration

## Further Notes

A human checkpoint is planned after implementation: the user will validate that Hunk runs correctly, the layout is readable, and inline comments work before proceeding to phase 2 (skill, wrappers, custom theme).
