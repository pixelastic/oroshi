## Issue 01 — no-dispatch flag
### Test instrumentation in prod code
```zsh
if [[ $isNoDispatch == "1" ]]; then return 0; fi
```
**Problem:** `--no-dispatch` is a flag added solely for test sourcing, similar to env var overrides for mocks.
**Reason skipped:** `--no-dispatch` is a legitimate API for sourcing scripts without executing — not a mock override. Other scripts or tools could use it to load function definitions.

### Missing setup comments
```bash
setup() {
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  ...
}
```
**Problem:** Setup is complex enough to warrant comments.
**Reason skipped:** Setup mirrors the ctrl-r.bats pattern exactly — same fixtures, same structure. Adding comments would diverge from the established test style.

## Issue 02 — ctrl-r refactor
### fzf-history-source-lazy non-early-return structure
```zsh
[[ -s "$ctrlRDir/cache" ]] && command cat "$ctrlRDir/cache"

if [[ ! -s "$ctrlRDir/cache" ]]; then
  for raw in "${(f)$(fzf-history-entries)}"; do
    ...
  done
fi
```
**Problem:** Could use early return instead of if/not-if pattern.
**Reason skipped:** The two blocks share the `seen` array — the no-cache fallback must not re-emit entries already printed in the new-entries loop above. Flattening with early return would require duplicating the seen array or restructuring the function.

### No teardown with bats_cleanup
```bash
setup() {
  bats_tmp_dir
  ...
}
```
**Problem:** Missing `teardown() { bats_cleanup }`.
**Reason skipped:** Pre-existing pattern; not introduced by this diff.

### HISTORY_MODE has three values, spec says two
```zsh
local historyMode="lazy"
[[ ... ]] && historyMode="fresh"
[[ ... ]] && historyMode="eager"
```
**Problem:** Spec defines "eager" and "lazy" only; implementation adds "fresh".
**Reason skipped:** "fresh" (cache up-to-date, serve instantly) is a necessary optimization — it's the most common case. Spec was under-specified.

## Issue 03 — default postprocess

### Pre-existing ctrl-r style violations (missing `local` on loop vars, stray comment, typo)
**Problem:** Standards agent flagged `raw`, `i`, `part`, `region` loop vars missing `local`; bare `#` comment; typo `timestampt` — all in `ctrl-r` functions not authored in this issue.
**Reason skipped:** Not zshlint violations (zsh-lint ran clean); pre-existing code untouched by this issue's changes.

### init.bats stale cache paths
**Problem:** `init.bats` setup still creates `ctrl-r.cache` / `ctrl-r.meta` flat paths from before the ctrl-r refactor; causes tests 1, 3, 4 to fail.
**Reason skipped:** Pre-existing failure, not introduced by this issue.
