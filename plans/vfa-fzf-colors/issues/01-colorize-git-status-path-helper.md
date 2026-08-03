## TLDR

Create `fzf-colorize-git-status-path` FZF Helper that combines a colored git status prefix with an extension-colored file path.

## What to build

A new FZF Helper at `scripts/bin/fzf/__lib/fzf-colorize-git-status-path.zsh` exporting a single function `fzf-colorize-git-status-path`.

Signature: `fzf-colorize-git-status-path <filepath> <gitStatus>` — writes result to `$REPLY`.

Behavior:
- Map git status to a prefix symbol and color:
  - `A` → `+` in `git-added` color
  - `M` → `~` in `git-modified` color
  - `D` → `-` in `git-removed` color
- Colorize the prefix with `colorize --reply`
- Colorize the filepath with `fzf-colorize-path` (directory green, basename by extension)
- Combine: `{colored prefix} {colored path}` (single space separator)
- Write final result to `$REPLY` (no subshell, no echo)

The helper sources `fzf-colorize-path.zsh` at the top.

## Behavioral Tests

Test file: `scripts/bin/fzf/__tests__/fzf-colorize-git-status-path.bats`

**Status prefix mapping:**
- modified file produces output containing `~`
- added file produces output containing `+`
- deleted file produces output containing `-`

**Path components:**
- output contains the filename
- output for a nested path contains the directory component

**ANSI coloring:**
- output contains ANSI escape sequences

## Acceptance criteria

- [ ] `fzf-colorize-git-status-path.zsh` created in `scripts/bin/fzf/__lib/`
- [ ] Function writes to `$REPLY`, no subshell
- [ ] All three status prefixes mapped correctly
- [ ] Uses `fzf-colorize-path` for the path portion
- [ ] Tests pass
- [ ] `bats-lint` and `zsh-lint` pass on new files
