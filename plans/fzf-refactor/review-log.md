## Issue 10 — ctrl-p

### Shebang #!/bin/zsh vs #!/usr/bin/env zsh
```zsh
#!/usr/bin/env zsh
```
**Problem:** Spec says `#!/bin/zsh` but script uses `#!/usr/bin/env zsh`
**Reason skipped:** All existing FZF Scripts use `#!/usr/bin/env zsh` (established in issue 02). Spec wording is aspirational; repo convention wins.

### fzf-source uses fd instead of git ls-files
```zsh
local items="$(fd --hidden --follow --color=never --type=file --base-directory "$searchPath" .)"
```
**Problem:** Spec says "tracked and untracked (non-ignored)" implying `git ls-files`, but `fd` is used
**Reason skipped:** `fd` respects `.gitignore` by default and is the pattern used by all other file-listing scripts (ctrl-shift-p, ctrl-o). Switching to `git ls-files` would diverge from established patterns.

### helpers/ vs __lib/ sourcing
```zsh
source "${0:h}/__lib/fzf-options-base.zsh"
source "${0:h}/__lib/fzf-options-prompt-directory.zsh"
```
**Problem:** Spec says "sources helpers/fs.zsh, helpers/git.zsh, and helpers/prompt.zsh" but script sources __lib/
**Reason skipped:** The repo migrated from helpers/ to __lib/ during issue 06-08. Spec predates the rename. __lib/ is the current convention.

### fzf-git-files-stageable-preview not a full FZF Script
```zsh
#!/usr/bin/env zsh
# fzf-git-files-stageable-preview — standalone preview script
```
**Problem:** Lives in `scripts/bin/fzf/` but doesn't follow the four-lifecycle-function pattern from GLOSSARY.md
**Reason skipped:** Preview helpers are external commands called by fzf's `--preview` flag. They're not FZF Scripts per the glossary — they're utility scripts that happen to live in the same directory.

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

## Issue 09 — git-file-history

### Standards: bats_git_dir name argument
```bats
bats_git_dir
```
**Problem:** Reviewer flagged missing name argument to `bats_git_dir`.
**Reason skipped:** All existing FZF Script tests (ctrl-o.bats, fzf-docker-images.bats) call `bats_git_dir` without a name arg — established pattern.

### Spec: helpers/git.zsh sourcing
**Problem:** Spec says "sourcing `helpers/git.zsh` from issue 08" but no such file exists.
**Reason skipped:** Issue 08 created `__lib/git.zsh` (renamed directory), and this script doesn't need any git helper — it calls `git` directly. The spec reference is outdated.

### Spec: shebang mismatch
**Problem:** Spec says `#!/bin/zsh`, script uses `#!/usr/bin/env zsh`.
**Reason skipped:** `#!/usr/bin/env zsh` is the standard shebang used by every FZF Script in the repo.

### Spec: no alias/function caller updated
**Problem:** Spec says "Update the git alias/function that previously called fzf-git-file-history".
**Reason skipped:** The `vfh` alias was already deleted in issue 01. No remaining callers exist in the codebase.

### Spec: preview behavior change
**Problem:** Legacy previewed diff of commit version vs working tree; new script previews commit vs parent.
**Reason skipped:** `git diff {1}^ {1}` is standard commit-diff preview, more useful for browsing history. Legacy behavior was unusual.

## Issue 10d — prompt convention

### Spec: "context-badge only, no path suffix" for git-root scoped scripts
```zsh
local prompt="$(fzf-options-prompt-directory "$gitRoot")"
```
**Problem:** Spec says git-root scoped prompt should be "context-badge only, no path suffix". `fzf-options-prompt-directory` always appends a path.
**Reason skipped:** `ctrl-p` and `ctrl-o` (also git-root scoped) both use `fzf-options-prompt-directory` with the same behavior and are marked ✓ in the spec. The helper's behavior is consistent across all git-root scripts; the spec description is a simplification, not a strict rule.

### Spec: "Verify all other scripts match the convention"
**Problem:** No diff evidence that other scripts were audited.
**Reason skipped:** The spec lists them all as ✓ already compliant. No code changes were expected or needed. Verification is by inspection of already-merged code, not by new tests.

---

## Issue 10b — init.zsh --preview and fzf-main override

### --format dispatch inside fzf-main
```zsh
fzf-main() {
  if [[ $isFormat == "1" ]]; then fzf-format; return 0; fi
```
**Problem:** `--format` is dispatched inside `fzf-main` (pipeline assembler), mixing dispatch and pipeline roles per GLOSSARY definition.
**Reason skipped:** `--format` is ctrl-p-specific, not a standard flag. It belongs in the overridden `fzf-main` since it's part of ctrl-p's custom pipeline logic — `fzf-dispatch` only dispatches the 4 standard flags.

### fzf-dispatch not in spec
```zsh
fzf-dispatch() {
  if [[ $isSource == "1" ]]; then fzf-source; return 0; fi
```
**Problem:** Spec says `fzf-main` remains the single entry point; `fzf-dispatch` is an architectural departure not mentioned in spec.
**Reason skipped:** Necessary to support the spec's own requirement that "scripts can override fzf-main". If dispatch lives inside fzf-main, overriding it loses dispatch.

### Spec file naming typo
```
fzf-git-files-dirty-stageable
```
**Problem:** Spec says `fzf-git-files-dirty-stageable` but actual file is `fzf-git-files-stageable`.
**Reason skipped:** File was created as `fzf-git-files-stageable` in issue 10. Spec has a naming typo.

## Issue 11 — ctrl-g (regexp-in-project)

### Spec: fold-case toggle behaviour not in regexp.zsh
```zsh
regexp-run() {
  local query="$1"
  local directory="$2"
  [[ "$query" == "" ]] && return 0
  rg --color=never --no-heading --with-filename --line-number --column -- "$query" "$directory" || true
}
```
**Problem:** Spec says `helpers/regexp.zsh` provides "fold-case toggle behaviour reused by both ctrl-g and ctrl-shift-g". The `--bind=f1:...` toggle from legacy `fzf-regexp-shared-options` is not implemented.
**Reason skipped:** The acceptance-criteria checklist does not list fold-case toggle as a required item. Implementing it now would require `fzf-var-read`/`fzf-var-write` infrastructure and is better done in issue 12 when the helper is actually shared with ctrl-shift-g.

## Issue 14 — Final legacy cleanup

### setopt local_options err_return missing from fzf-var.zsh functions
**Problem:** Standards agent flagged that `fzf-var-write` and `fzf-var-read` function bodies lack `setopt local_options err_return`.
**Reason skipped:** `fzf-var.zsh` is a `__lib/` sourced helper, not a standalone autoload. Other `__lib/` helpers (`fzf-options-prompt-directory.zsh`, `fzf-colorize-path.zsh`) follow the same pattern — no `setopt` inside function bodies. The parent script's `set -e` provides error protection.

### New scripts created "beyond spec scope"
**Problem:** Spec agent flagged `fzf-kitty-tabs`, `fzf-fs-shared-preview`, `fzf-fs-shared-preview-header` as unspecified additions.
**Reason skipped:** These were necessary prerequisites to delete the legacy autoloads that called them. The spec says "replaced by FZF Helpers sourced directly" (line 11) and "Any autoloads not yet deleted" — creating replacements is implied. Without them, `autoload/fzf/` could not be fully removed.
