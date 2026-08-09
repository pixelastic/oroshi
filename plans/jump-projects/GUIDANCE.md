## Guidance

### Testing

- Run ZSH tests: `bats <filepath>`
- Lint ZSH: `zsh-lint <filepath>`
- Lint BATS: `bats-lint <filepath>`
- Tests live in `__tests__/` directories alongside or near their source

### Key locations (relative to repo root)

- Autoloaded functions: `tools/term/zsh/config/functions/autoload/misc/mark/`
- Completion helpers: `tools/term/zsh/config/functions/autoload/completion/`
- Compdef wrappers: `tools/term/zsh/config/completion/compdef/`
- Compdef registration: `tools/term/zsh/config/completion/compdef.zsh`
- Alias file: `tools/term/zsh/config/aliases/mark.zsh`
- Projects dist: `tools/term/zsh/config/theming/dist/projects.zsh`
- Projects loader: `tools/term/zsh/config/functions/autoload/context/project/projects-load-definitions`

### Conventions

- `mark-list-raw` output uses `▮` separator (consistent with `helper-list-raw`)
- Autoloaded functions start with `setopt local_options err_return`
- Functions use `return` not `exit`
- Test mocking: use `bats_tmp_dir` for temp directories, `bats_mock_env` for env vars
- `PROJECTS` array: keys are `name:field` (e.g., `foo:path`, `foo:icon`). Load via `projects-load-definitions`
- Project paths contain `~` — use `${~var}` for tilde expansion in ZSH
- `_jumps` compdef pattern: call `complete-*` helper, pipe to `_describe`
- Nerd font glyphs (U+E000-U+F8FF): do NOT use Write tool on files containing them — use Edit only

### Prior art

- `helper-list-raw` / `helper-list` — same raw+formatted pattern with `▮` separator
- `_jumps` compdef — existing pattern for completion wrappers
- `scripts/bin/mark` — current symlink creation logic (to be replaced)
- `misc/__tests__/helper-list-raw.bats` — reference test patterns

## Discoveries

(none yet)
