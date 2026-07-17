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
