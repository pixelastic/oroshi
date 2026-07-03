## TLDR

Update both `ctrl-p` and `ctrl-shift-p` to delegate to the shared `fzf-options-files` helper.

## What to build

**`ctrl-p`:**
- Replace the `source fzf-options-base.zsh` and `source fzf-options-prompt-directory.zsh` lines with a single `source fzf-options-files.zsh`
- Replace the `fzf-options()` body with a single delegation: `fzf-options-files "$SCRIPT_NAME" "$SEARCH_PATH"`

**`ctrl-shift-p`:**
- Add a top-level `SEARCH_PATH="$PWD"` variable (same pattern as `ctrl-p`)
- Replace the two source lines (`fzf-options-base`, `fzf-options-prompt-directory`) with `source fzf-options-files.zsh`
- Align source order to match `ctrl-p`: `init` → `fzf-options-files` → `fzf-source-files` → `fzf-fs-preview`
- Replace `fzf-options()` body with `fzf-options-files "$SCRIPT_NAME" "$SEARCH_PATH"`
- Use `$SEARCH_PATH` in `fzf-source()` instead of inlining `$PWD`
- Drop `--nth=1,2` (was inlined in the old `fzf-options()` — now gone)

After this issue, the only difference between the two scripts is the value assigned to `SEARCH_PATH`.

## Acceptance criteria

- [ ] `ctrl-p` sources only `fzf-options-files.zsh` (not `fzf-options-base` or `fzf-options-prompt-directory` directly)
- [ ] `ctrl-p`'s `fzf-options()` is a one-liner delegation
- [ ] `ctrl-shift-p` has `SEARCH_PATH="$PWD"` at top level
- [ ] `ctrl-shift-p` source order matches `ctrl-p`
- [ ] `ctrl-shift-p`'s `fzf-options()` is a one-liner delegation
- [ ] `ctrl-shift-p` no longer contains `--nth=1,2`
- [ ] `zsh-lint` passes on both files
- [ ] Existing bats tests pass for both scripts (`ctrl-p.bats`, `ctrl-shift-p.bats`)
