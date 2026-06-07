## Issue 02 — ctrl-r

### Dispatch: `case "$1"` vs `zparseopts`
```zsh
zparseopts -D -E \
  -source=flagSource \
  -options=flagOptions \
  -postprocess=flagPostprocess
...
if [[ $isSource == "1" ]]; then fzf-source
elif [[ $isOptions == "1" ]]; then fzf-options
...
```
**Problem:** Issue spec explicitly requires `case "$1"` dispatch as the pattern all subsequent scripts must follow. Implementation uses `zparseopts` + if/elif instead.
**Reason skipped:** `zsh-lint` enforces `noManualArgParsing` which disallows `case "$1"` for arg parsing. Linter compliance takes precedence; subsequent scripts must use the same zparseopts pattern.

### `bat` syntax highlighting not carried over
```zsh
# legacy fzf-history-source had:
bat --language=sh --paging=never --decorations=never --color=always
```
**Problem:** New `fzf-source` drops `bat` coloring silently — behavioral regression.
**Reason skipped:** Issue spec says ctrl-r is "deliberately the simplest possible FZF Script — no preview". Omitting `bat` is intentional.
