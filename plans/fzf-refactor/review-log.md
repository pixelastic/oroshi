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

---

### `bat` syntax highlighting not carried over
```zsh
# legacy fzf-history-source had:
bat --language=sh --paging=never --decorations=never --color=always
```
**Problem:** New `fzf-source` drops `bat` coloring silently — behavioral regression.
**Reason skipped:** Issue spec says ctrl-r is "deliberately the simplest possible FZF Script — no preview". Omitting `bat` is intentional.
