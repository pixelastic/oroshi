## Guidance

### Goal
Create an `icons-build` pipeline that generates `dist/icons.zsh` and `dist/icons.json` from a JSONC source, replacing the static `icons.zsh`.

### Testing commands
- Run bats tests: `bats tools/term/zsh/config/functions/autoload/icons/__tests__/<file>.bats`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`

### File locations (relative to repo root)
- Source: `tools/term/zsh/config/theming/src/icons.jsonc` (new)
- Build script: `tools/term/zsh/config/functions/autoload/icons/icons-build` (new)
- Loader: `tools/term/zsh/config/functions/autoload/icons/icons-load-definitions` (update)
- Dist zsh: `tools/term/zsh/config/theming/dist/icons.zsh` (generated)
- Dist json: `tools/term/zsh/config/theming/dist/icons.json` (generated)
- Tests (new): `tools/term/zsh/config/functions/autoload/icons/__tests__/icons-build.bats`
- Tests (update): `tools/term/zsh/config/functions/autoload/icons/__tests__/icons-load-definitions.bats`
- Orchestrator: `scripts/bin/colors-refresh`
- Lint-staged: `lintstaged.config.js`

### Conventions
- Autoload functions use `setopt local_options err_return` (not `set -e`; that's for bin scripts with shebang)
- Dist zsh files start with `# zsh-lint disable-file=commandTooLong`
- Bats tests: all variables defined in `setup()`, use `bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"`, call scripts via `bats_run_zsh`
- `cd` inside `bats_run_zsh` subprocess: `bats_run_zsh "cd $dir && fn"`, never `cd` before
- Use `$OROSHI_ROOT` (never hardcoded paths)
- JSONC → JSON conversion: use `jsonc2json` utility (already used by `colors-build` and `filetypes-build`)

### Prior art
- `colors-build` — model for the build script structure and jq flattening pattern
- `colors-build.bats` — model for the bats test setup
- `filetypes-build` — closest model (also calls `icons-load-definitions`)

## Discoveries

<!-- Agents: append findings after each issue below -->

### Issue 01 — Migrate source data

- `jsonc2json` strips only standalone `//` comment lines; trailing inline comments (e.g. `"key": "val", // note`) are NOT stripped and produce invalid JSON. Use standalone comment lines only.
- Categories with both a bare key and prefixed keys (`node`, `ruby`, `claude`) cannot be nested under a single object key in JSON — they must remain flat. The `paths | join("-")` flattening from `colors-build` handles both flat and nested entries correctly.
- `docker-image` was defined twice in the original `icons.zsh` (once as `"G"`, once as the glyph); the glyph value was kept, documented with a comment.
- **Ne pas supprimer `icons.zsh` dans l'issue 01** — la suppression doit avoir lieu dans l'issue 02, après que `icons-load-definitions` source `dist/icons.zsh`. Sinon tout plante.
