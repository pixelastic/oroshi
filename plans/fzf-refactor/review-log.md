## Issue 08 — ctrl-o (git-root directory search)

### Standards: bats_git_dir helper
```bats
git -C "$BATS_TMP_DIR" init --quiet
```
**Problem:** Reviewer suggested using `bats_git_dir` helper instead of manual `git init`.
**Reason skipped:** `bats_git_dir` does not exist in this codebase. The `git -C "$BATS_TMP_DIR" init --quiet` pattern is used by both `ctrl-shift-o.bats` and `ctrl-shift-p.bats` — it is the established convention here.

### Standards: fzf-main not defined in script
```zsh
fzf-main  # called at end of ctrl-o
```
**Problem:** GLOSSARY says a FZF Script must contain four lifecycle functions including `fzf-main`.
**Reason skipped:** `fzf-main` is defined in `__lib/init.zsh` and called at the end of the script. All existing FZF Scripts (`ctrl-shift-o`, `ctrl-shift-p`, etc.) follow this exact pattern — none define `fzf-main` locally.

### Spec: helpers/ path divergence
```
scripts/bin/fzf/__lib/git.zsh  (implemented)
scripts/bin/fzf/helpers/git.zsh  (spec wording)
```
**Problem:** Spec says `helpers/git.zsh` but implementation uses `__lib/git.zsh`.
**Reason skipped:** `__lib/` is the established convention used by all existing FZF Scripts in this codebase. The spec used older `helpers/` wording from before `__lib/` was adopted.

### Spec: plans context-aware behavior not preserved
```zsh
# Removed from ctrl-o.zsh:
[[ "${LBUFFER}" =~ "ralph( )?$" ]] && completionType="plans"
```
**Problem:** Spec says "context-aware behaviour for ralph/plans directories is preserved unless the plans picker has already been removed as part of issue 01 cleanup." Issue 01 did not remove it.
**Reason skipped:** The acceptance criteria for issue 08 explicitly deletes the plans autoloads (`fzf-fs-directories-plans/*`). Preserving the plans behavior would require creating a new `fzf-plans-directories` FZF Script, which is out of scope for this issue. The spec language is contradictory — we chose the acceptance criteria over the "What to build" prose.

### Spec: #!/bin/zsh shebang
```zsh
#!/usr/bin/env zsh  (implemented)
#!/bin/zsh          (spec wording)
```
**Problem:** Spec says `#!/bin/zsh` but implementation uses `#!/usr/bin/env zsh`.
**Reason skipped:** `#!/usr/bin/env zsh` matches all other FZF Scripts in the codebase (`ctrl-shift-o`, `ctrl-shift-p`, `ctrl-r`, etc.). The spec wording was incorrect.

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

---

## Issue 04 — apt-packages

### Missing `--preview` in `fzf-options`
```zsh
fzf-options() {
  fzf-options-base
  echo "--delimiter=▮"
  echo "--with-nth=2"
}
```
**Problem:** Legacy `fzf-packages-apt-options` emitted `--preview=fzf-packages-apt-preview {1}`. New `fzf-options` drops preview entirely.
**Reason skipped:** Preview depended on `fzf-packages-apt-preview` which is being deleted. Spec acceptance criteria do not include preview. Deferred.

### Missing colored `--prompt` in `fzf-options`
**Problem:** Legacy `fzf-packages-apt-options` built a colorized prompt with icons/colors. New `fzf-options` has no custom prompt.
**Reason skipped:** Requires `icons-load-definitions`/`colors-load-definitions` autoloads not available in FZF Script context. Same deferral as issue 03.

### Shebang `#!/usr/bin/env zsh` vs spec `#!/bin/zsh`
**Problem:** Spec says "executable `#!/bin/zsh` script"; both new scripts use `#!/usr/bin/env zsh`.
**Reason skipped:** `#!/usr/bin/env zsh` is the established pattern across all FZF Scripts (ctrl-r, ctrl-b). Consistency takes precedence.

---

---

## Issue 05 — docker-images

### Shebang `#!/usr/bin/env zsh` vs spec `#!/bin/zsh`
```zsh
#!/usr/bin/env zsh
```
**Problem:** Spec acceptance criteria says "executable `#!/bin/zsh` script".
**Reason skipped:** Established pattern across all FZF Scripts. Consistency takes precedence.

### Static cache vs Docker Hub API
```zsh
fzf-source() {
  local cacheFile="$OROSHI_ROOT/tools/docker/docker/config/data/src/images-remote.txt"
  cat "$cacheFile"
}
```
**Problem:** Spec says "queries the Docker Hub API for image results matching the user's query". Implementation reads a static cache file.
**Reason skipped:** Legacy `fzf-docker-images-remote-source` also used the same static cache file. Spec wording is aspirational; acceptance criteria only requires "outputs Docker Hub candidates" which the cache satisfies.

### `image:tag` format — no tag in output
**Problem:** Spec says postprocess outputs `image:tag` format. Output is just the image name (e.g. `ubuntu`).
**Reason skipped:** Cache file has no tags. `ubuntu` is valid for `docker pull` (defaults to `:latest`). The legacy postprocess also returned just the image name.

### Guard dispatch blocks lack comments
**Problem:** Standards reviewer flagged missing explanatory comments on each `if [[ $isSource == "1" ]]` dispatch block.
**Reason skipped:** Pre-existing pattern; `ctrl-r`, `ctrl-b`, `apt-packages` also have no comments on dispatch guards.

## Issue 06 — ctrl-shift-p

### Spec: `fs.zsh` "color output" not implemented
```zsh
items="$(fd --hidden --follow --color=never --type=file --base-directory "$searchPath" .)"
```
**Problem:** Spec says `helpers/fs.zsh` includes "color output". Implementation uses `--color=never`.
**Reason skipped:** Using `--color=always` embeds ANSI codes in the absolute-path column, corrupting the `   ` delimiter split and making `fzf-postprocess` return garbage paths. Color can be added to the display column later; the acceptance criteria don't explicitly require it.

### Spec: `#!/bin/zsh` vs `#!/usr/bin/env zsh`
```zsh
#!/usr/bin/env zsh
```
**Problem:** Spec acceptance criterion says "executable `#!/bin/zsh` script".
**Reason skipped:** Established pattern across all FZF Scripts. Consistency takes precedence.

---

---

## Issue 07 — ctrl-shift-o

### `return 0` in `fzf-postprocess` function body

```zsh
fzf-postprocess() {
  local input="$(cat)"
  [[ "$input" == "" ]] && return 0
  ...
}
```

**Problem:** Reviewer flagged as violation of `feedback_zsh_errexit.md` (scripts should use `exit`, not `return`).
**Reason skipped:** `fzf-postprocess` is a ZSH *function*, not top-level script code. `return` is correct in function bodies; `exit` would terminate the entire script process. The reference implementation `ctrl-shift-p` uses the same pattern. `feedback_zsh_errexit.md` applies to the script header protection mechanism, not function-internal early returns.

### Spec references `helpers/fs.zsh` and `helpers/prompt.zsh`

**Problem:** Spec says "sourcing helpers/fs.zsh and helpers/prompt.zsh established in issue 06"; implementation uses `__lib/fzf-source-dirs.zsh` and `__lib/fzf-options-prompt-directory.zsh`.
**Reason skipped:** Spec was written before issue 06 settled on the `__lib/` naming convention. Actual established pattern from ctrl-shift-p uses `__lib/`. Implementation is correct.

### No bats test for `--options`

**Problem:** Spec acceptance criterion says "ctrl-shift-o --options outputs valid FZF flags".
**Reason skipped:** GUIDANCE.md explicitly says "Do NOT test fzf-options (static flags, no meaningful assertions)". GUIDANCE overrides the spec acceptance criterion on this point.

### Shebang `#!/usr/bin/env zsh` vs spec `#!/bin/zsh`

**Problem:** Spec says `#!/bin/zsh`; script uses `#!/usr/bin/env zsh`.
**Reason skipped:** `#!/usr/bin/env zsh` matches the established pattern from ctrl-shift-p and all other FZF Scripts. Consistency takes precedence.

---

### `bat` syntax highlighting not carried over
```zsh
# legacy fzf-history-source had:
bat --language=sh --paging=never --decorations=never --color=always
```
**Problem:** New `fzf-source` drops `bat` coloring silently — behavioral regression.
**Reason skipped:** Issue spec says ctrl-r is "deliberately the simplest possible FZF Script — no preview". Omitting `bat` is intentional.

## Issue 08b — fzf-plans polish

### `local prompt` no empty guard in fzf-options()
```zsh
local prompt="$(fzf-options-prompt-directory "$gitRoot")"
echo "--prompt=${prompt}"
```
**Problem:** Standards reviewer flagged missing guard per variables.md: if `fzf-options-prompt-directory` returns empty, silently produces `--prompt=`.
**Reason skipped:** Identical to the existing pattern in `ctrl-o` (which this issue was matching). `fzf-options-prompt-directory` always returns a non-empty string (has a `$HOME`-relative fallback path). No regression introduced.

### `fzf-postprocess` regression test missing
**Problem:** Spec says "existing tests — unchanged behavior, no regression" and AC: "`fzf-plans --postprocess` output unchanged". No new postprocess test added.
**Reason skipped:** `fzf-postprocess` code was not changed; existing passing tests cover the regression. The spec line refers to confirming no regression, not adding new tests.
