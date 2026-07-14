## Issue 01 — file-hash speedup

### bats_disable_worktree_aware not used
```bash
bats_run_zsh "file-hash $BATS_TMP_DIR/a.txt"
```
**Problem:** Tests run file-hash on files outside the worktree without `bats_disable_worktree_aware`.
**Reason skipped:** `file-hash` doesn't call any worktree-aware functions — no PATH/fpath issue possible.

### head -c vs head --bytes
```bash
head --bytes 1048576 "$input"
```
**Problem:** Spec says `head -c 1048576`, implementation uses `head --bytes`.
**Reason skipped:** Long-form args is the project convention per `calling-commands.md`. Functionally equivalent.

### 10-char truncation not in spec
```bash
echo ${${hash%% *}[1,10]}
```
**Problem:** Spec doesn't mention truncation; reduces collision resistance.
**Reason skipped:** User explicitly requested 10-char limit during session. Collision resistance is sufficient for cache keys.

## Issue 03 — video-thumbnail

### Long-form args on ffprobe/ffmpeg
```zsh
ffprobe \
	-v quiet \
	-show_entries format=duration \
	-of default=noprint_wrappers=1:nokey=1 \
	"$input"
```
**Problem:** Reviewer flagged `-v` as short-form violating `calling-commands.md` long-form rule.
**Reason skipped:** ffmpeg/ffprobe flags (`-v`, `-i`, `-vf`, `-y`) have no GNU-style `--long-form` equivalents — these are the canonical forms.

### Negated guard style
```zsh
[[ ! -f "$input" ]] && return 1
```
**Problem:** Reviewer noted negated condition differs from positive-form convention examples.
**Reason skipped:** `zshlint` enforces this form via `noOrGuard` rule — `[[ -f ]] || return` was rejected by the linter.
