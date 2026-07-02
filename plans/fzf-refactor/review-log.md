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
