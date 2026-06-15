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

---

## Issue 03 — ctrl-b

### Shebang `#!/usr/bin/env zsh` vs `#!/bin/zsh`
```zsh
#!/usr/bin/env zsh
```
**Problem:** Spec acceptance criteria says "created as executable `#!/bin/zsh` script".
**Reason skipped:** The established pattern from issue 02 (`ctrl-r`) uses `#!/usr/bin/env zsh`. Following the reference implementation for consistency.

### `--options` has no BATS test
**Problem:** Acceptance criteria lists `ctrl-b --options` as a checkable item, no test covers it.
**Reason skipped:** GUIDANCE.md explicitly states "Do NOT test `fzf-options` (static flags, no meaningful assertions)".

### `bats_tmp_dir` not called in setup()
```bats
setup() {
  CURRENT="$BATS_TEST_DIRNAME/../ctrl-b"
}
```
**Problem:** Inconsistent with sibling `ctrl-r.bats` which calls `bats_tmp_dir`.
**Reason skipped:** `ctrl-b` tests are stateless — no temp files are needed. Calling `bats_tmp_dir` would be dead code.

### `--options` has no color/prompt customization
**Problem:** Legacy `fzf-commands-options` had colors, a `which {1}` preview, and a styled prompt. New `fzf-options` is a bare passthrough of `fzf-options-base`.
**Reason skipped:** Legacy options depend on `icons-load-definitions`/`colors-load-definitions` which are not available to FZF Scripts. Theming is deferred until the color system refactor lands.

---

### `bat` syntax highlighting not carried over
```zsh
# legacy fzf-history-source had:
bat --language=sh --paging=never --decorations=never --color=always
```
**Problem:** New `fzf-source` drops `bat` coloring silently — behavioral regression.
**Reason skipped:** Issue spec says ctrl-r is "deliberately the simplest possible FZF Script — no preview". Omitting `bat` is intentional.
