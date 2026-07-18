## Guidance

- Shell scripts live in `scripts/bin/kitty/`, tests in `scripts/bin/kitty/__tests__/`
- Python modules live in `tools/term/kitty/config/lib/`, tests in `tools/term/kitty/config/lib/__tests__/`
- Run bats tests: `bats <filepath>`
- Run python tests: `python-test <filepath>`
- Lint shell scripts: `zsh-lint <filepath>`
- Lint bats files: `bats-lint <filepath>`
- Shell scripts use `set -e` (shebang scripts), not `setopt local_options err_return`
- Bats tests use `bats_mock` for command stubs, `bats_mock_env` for env overrides, `bats_run_zsh` to execute
- Existing kitty bats tests (`kitty-reload.bats`, `kitty-tab-attention-add.bats`) are prior art
- Glossary lives at `tools/term/kitty/config/GLOSSARY.md` — use its vocabulary
- The Reload Beacon path is `$OROSHI_TMP_FOLDER/kitty/beacons/reload`
- `git-worktree-is-oroshi` already includes the `git-directory-is-worktree` check

## Discoveries

### Issue 05 — debug attention autoclear
- Kitty holds the GIL between render cycles; `threading.Timer` callbacks cannot fire on idle tabs (no render activity releases the GIL).
- Use `add_timer` from `kitty.fast_data_types` instead of `threading.Timer` — it runs in kitty's event loop, bypassing the GIL issue entirely.
- Use `get_boss().active_tab_manager.mark_tab_bar_dirty()` to force a tab bar repaint after clearing attention. Without it, the icon persists until the next organic repaint.
- `subprocess.run` from a Timer thread fails with "open /dev/tty: no such device or address" — attention removal must be done via direct file manipulation, not shelling out to `kitty-tab-attention-remove`.
- `import time` during `exec_module` reload breaks the render pipeline.
- `rm -f` is aliased to `trash-put` which errors on non-existent files — use `;` not `&&`.
- The statusbar (`statusbar.py`) already uses `add_timer` and `mark_tab_bar_dirty` — prior art for the pattern.
