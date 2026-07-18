## Guidance

- ZSH autoload functions — use `zsh-writer` skill
- Tests — bats framework, run with `bats <filepath>`, lint with `bats-lint <filepath>`
- Test helpers — use `bats_run_zsh`, `bats_mock`, `bats_mock_env` (see memory `feedback_bats_stub_path.md`)
- Test vars go in `setup()`, not file top level
- ZSH lint — run with `zsh-lint <filepath>`
- Errexit — use `setopt local_options err_return` for autoload functions
- Local vars — use `local var="$(cmd)"` pattern
- Flag tests — use `[[ $flag == "1" ]]` not `(( flag ))`
- Existing functions live in `tools/term/zsh/config/functions/autoload/yarn/`
- New workspace functions go in `tools/term/zsh/config/functions/autoload/yarn/workspace/`
- `▮` separator is used throughout `*-list-raw` functions for machine-parseable output
- `jq` is used for JSON parsing (see `yarn-script-list-raw`, `yarn-package-binaries` for patterns)
- `git-directory-root` already accepts an optional path argument
- `yarn-link-create` handles per-module symlinking + binary linking — no changes needed
- Aberlaas monorepo root: `/home/tim/local/www/projects/aberlaas`
- Aberlaas workspaces glob: `["modules/*"]` in root `package.json`

## Discoveries

### Issue 02 — yarn-workspace-list-raw
- `path` is a reserved ZSH variable (array tied to `$PATH`) — never use it as a local variable name; use `targetPath` instead
- `print $output` works the same as `echo $output` for `\n` interpretation in ZSH — both are valid
