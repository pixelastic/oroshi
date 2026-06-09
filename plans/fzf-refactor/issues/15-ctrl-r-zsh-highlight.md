## TLDR

Replace `bat` coloring in `ctrl-r` with `zsh-syntax-highlighting` — same semantic colors as the live prompt, line by line.

## Prerequisites

This issue requires the color system refactor to be merged into main first:
the current `ZSH_HIGHLIGHT_STYLES` config references `COLOR_ALIAS_*` environment variables.
Once those are replaced by a ZSH associative array, sourcing the styles from inside `ctrl-r` becomes clean.

## What to build

Enhance `scripts/bin/fzf/ctrl-r` to colorize history entries using `_zsh_highlight()` from the
`zsh-syntax-highlighting` plugin — the same function that colors the live prompt. Each line is
highlighted independently, so a malformed command on one line cannot affect the display of others.

### Source output format

`fzf-source` switches from a single colored string to a `▮`-separated dual-field format:

```
raw_command▮colored_command
```

- **Field 1** (`raw_command`): plain text — what gets inserted into `$LBUFFER`
- **Field 2** (`colored_command`): ANSI-colored via `_zsh_highlight()` — what fzf displays

### FZF options changes

```
--delimiter=▮
--with-nth=2      # display only the colored field
--nth=2           # search only in the colored field (fzf strips ANSI for matching)
```

### Postprocess changes

Split on `▮`, return field 1 (raw). No ANSI stripping needed.

### Highlighting function

Add an internal function `fzf-highlight-line` inside `ctrl-r` (not a separate helper):

```zsh
fzf-highlight-line() {
  # Given a plain command string on stdin, outputs an ANSI-colored version
  # Uses _zsh_highlight() from zsh-syntax-highlighting, set up with current ZSH_HIGHLIGHT_STYLES
  local line="$1"
  local BUFFER="$line"
  local CURSOR=${#line}
  local -a region_highlight
  _zsh_highlight
  # Convert region_highlight entries ("start end fg=N,...") to ANSI escape sequences
  # applied to $BUFFER, then print the colored result
}
```

The `region_highlight` entries have the format `"start end spec"` where `spec` is like `fg=123` or
`fg=17,bold`. Convert `fg=N` → `\e[38;5;Nm`, `bg=N` → `\e[48;5;Nm`, `bold` → `\e[1m`.

### Sourcing strategy

At the top of `ctrl-r`, after the existing `source "${0:h}/helpers/options.zsh"`:

```zsh
source "$OROSHI_ROOT/tools/term/zsh/config/tools/zsh.zsh"
```

This loads `_zsh_highlight` and `ZSH_HIGHLIGHT_STYLES` (with the refactored color system).
Done once per `ctrl-r --source` invocation — acceptable startup cost (~200-500ms).

### Fallback

If `zsh-syntax-highlighting` is not installed, `fzf-source` emits `raw▮raw` (no coloring,
no error). Guard: `[[ $isHighlighting == "1" ]] || colored="$line"`.

## Behavioral Tests

**fzf-source**
- Outputs `raw▮colored` format (two fields separated by `▮`)
- Field 1 contains no ANSI codes
- Field 2 contains ANSI codes for a known command

**fzf-postprocess**
- Given `raw▮colored` on stdin, outputs only the raw field

**fzf-options**
- Output includes `--delimiter=▮`, `--with-nth=2`, `--nth=2`

## Acceptance criteria

- [ ] `ctrl-r --source` outputs `raw▮ansi-colored` per history entry
- [ ] Coloring uses `_zsh_highlight()` with `ZSH_HIGHLIGHT_STYLES` (not `bat`)
- [ ] Each line is highlighted independently — one bad line cannot break others
- [ ] `ctrl-r --postprocess` returns the raw field (no ANSI in the inserted command)
- [ ] `ctrl-r --options` includes `--delimiter=▮ --with-nth=2 --nth=2`
- [ ] Fallback to `raw▮raw` when `zsh-syntax-highlighting` is not installed
- [ ] BATS tests pass
- [ ] `zsh-lint` passes on all modified files
