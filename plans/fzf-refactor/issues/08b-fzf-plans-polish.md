## TLDR

Polish `fzf-plans` UX to match `ctrl-o`: colored directory names with trailing slash, preview window, and context badge prompt. Also update `fzf-source-directories` so `ctrl-o` benefits from the same visual treatment.

## What to build

**`scripts/bin/fzf/__lib/fzf-source-directories.zsh`** — colorize the display column (2nd field) with `COLORS[directory]` and append a trailing `/`. The first field (absolute path) stays clean for postprocess. Add `colors-load-definitions` call before the loop.

**`scripts/bin/fzf/fzf-plans`** — three additions to match `ctrl-o`:

1. **Colored source with trailing slash** — in `fzf-source()`, after calling `plan-list-raw`, colorize the basename field with `COLORS[directory]` and append `/`. The first field stays clean so `fzf-postprocess` is unaffected.
2. **Preview window** — in `fzf-options()`, add `--preview=fzf-fs-shared-preview {1}` (same as `ctrl-o`).
3. **Context badge prompt** — source `fzf-options-prompt-directory.zsh`, call `fzf-options-prompt-directory` with the git root, emit `--prompt=`.

## Behavioral Tests

**fzf-source-directories**
- Given a directory with subdirectories, each output line's second field is ANSI-colored and ends with `/`
- Given a directory with subdirectories, each output line's first field is a plain absolute path (no ANSI, no slash)

**fzf-plans fzf-source**
- Given a git repository with a `plans/` directory, each output line's second field is ANSI-colored and ends with `/`
- Given a git repository with a `plans/` directory, each output line's first field is a plain absolute path (no ANSI, no slash)

**fzf-plans fzf-postprocess**
- (existing tests — unchanged behavior, no regression)

## Acceptance criteria

- [ ] `fzf-source-directories` second field is colorized with `COLORS[directory]` and ends with `/`
- [ ] `fzf-source-directories` first field remains a plain absolute path
- [ ] `ctrl-o` (which uses `fzf-source-directories`) displays colored entries with trailing slash
- [ ] `fzf-plans --source` second field is colorized with `COLORS[directory]` and ends with `/`
- [ ] `fzf-plans --source` first field remains a plain absolute path
- [ ] `fzf-plans --postprocess` output unchanged (plain absolute path, no slash, no ANSI)
- [ ] `fzf-plans` in interactive mode shows a directory preview via `fzf-fs-shared-preview`
- [ ] `fzf-plans` in interactive mode shows git-root context badge as `--prompt`
- [ ] BATS tests for modified source functions pass
- [ ] `zsh-lint` passes on all modified files
