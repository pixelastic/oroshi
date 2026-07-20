## Guidance

- Testing zsh: `bats <filepath>`
- Linting zsh: `zsh-lint <filepath>`
- Filetypes source: `tools/term/zsh/config/theming/src/filetypes.jsonc`
- Filetypes dist: `tools/term/zsh/config/theming/dist/filetypes.zsh`
- Filetypes build: run `filetypes-build` (autoload function)
- `--reply` pattern prior art: `tools/term/zsh/config/functions/autoload/misc/simplify-path`
- `filetypes-group` tests: `tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-group.bats`
- `git-file-edit` tests: `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-edit.bats`
- Mock pattern: use `bats_mock` for immediate collaborators (London school)
- Use `local var="$(cmd)"` pattern, never split local/assignment
- Use `[[ $flag == "1" ]]` for boolean tests, not `(( flag ))`
- Use `setopt local_options err_return` for autoload functions (not `set -e`)

## Discoveries
