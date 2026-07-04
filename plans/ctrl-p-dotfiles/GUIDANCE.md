## Guidance

### Plan goal

Fix ctrl-p (fzf file picker) mishandling of dotfile config files: sort order, list color, preview header icon+color, and filetype group resolution.

### Key insight: FILETYPES key derivation

The compiled `dist/filetypes.zsh` uses this convention for dotfile keys:
- `.fdignore` → key `_fdignore` (dots replaced by underscores, lowercased)
- This matches the `filetypes-build` compile step: `ascii_downcase | gsub("[.]";"_")`

The new `filetypes-key` function (issue 01) centralizes this logic. All other issues call it.

### Testing commands

```
bats <filepath>          # run bats tests
zsh-lint <filepath>      # lint zsh files
bats-lint <filepath>     # lint bats files
```

### File locations (relative to repo root)

| File | Role |
|---|---|
| `tools/term/zsh/config/functions/autoload/filetypes/filetypes-key` | New helper (issue 01) |
| `tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-key.bats` | Tests for issue 01 |
| `tools/term/zsh/config/functions/autoload/misc/sort-filepaths` | Sort logic (issue 02) |
| `tools/term/zsh/config/functions/autoload/misc/__tests__/sort-filepaths.bats` | Tests for issue 02 |
| `scripts/bin/fzf/__lib/fzf-colorize-path.zsh` | List colorization (issue 03) |
| `scripts/bin/fzf/__lib/__tests__/fzf-colorize-path.bats` | Tests for issue 03 |
| `scripts/bin/fzf/__lib/fzf-fs-preview.zsh` | Preview header (issue 04) |
| `scripts/bin/fzf/__lib/__tests__/fzf-fs-preview.bats` | Tests for issue 04 |
| `tools/term/zsh/config/functions/autoload/misc/filetype-group` | Group lookup (issue 05) |
| `tools/term/zsh/config/theming/dist/filetypes.zsh` | Compiled filetypes (read-only reference) |
| `tools/term/zsh/config/theming/src/filetypes.jsonc` | Source of truth for filetype definitions |
| `tools/term/zsh/config/functions/autoload/filetypes/filetypes-build` | Compile step — reference for key derivation logic |

### Conventions

- `$REPLY` pattern: functions that compute a value write to `$REPLY` (no subprocess). See `colorize --reply`, `fzf-colorize-path`.
- Autoload functions use `setopt local_options err_return` (not `set -e`).
- Bats tests: all variables in `setup()`, never at file top level.
- Bats tests: use `bats_run_zsh "fn args"` — never call binaries directly.
- Bats tests: use `bats_mock` for collaborators, not env var overrides in prod code.
- `filetypes-load-definitions` is a no-op if FILETYPES already populated — mock it in tests.

### Prior art

- `filetype-group` — existing autoload that resolves group from extension (to be updated in issue 05)
- `fzf-colorize-path.bats` — mock pattern for `filetypes-load-definitions` and `colors-load-definitions`
- `sort-filepaths.bats` — pattern for testing autoload sort functions

## Discoveries

_Append findings here after each issue, in the format:_

### Issue XX — short title
- Finding 1
- Finding 2
