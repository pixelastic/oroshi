## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `term` domain into `tools/term/`. This domain is done last because `config/term/zsh/` contains ZSH configs (aliases, env vars, tools configs) that cross-reference many other domains — updating those refs is easier once the target paths already exist.

Tools: `kitty` (install + deploy + config), `zsh` (install + deploy + config), `bats` (config only).

The entire `config/term/zsh/` tree — including `aliases/`, `functions/`, `completion/`, `plugins/`, `prompt/`, `theming/`, `tools/`, `local/`, and all `.zsh` files — moves into `tools/term/zsh/config/`. The ZSH autoload functions at `config/term/zsh/functions/autoload/` move naturally as part of this.

## Acceptance criteria

- [ ] `tools/term/` directory created
- [ ] `scripts/install/term/kitty` moved to `tools/term/kitty/install`
- [ ] `scripts/install/term/zsh` moved to `tools/term/zsh/install`
- [ ] `scripts/deploy/term/kitty` moved to `tools/term/kitty/deploy`
- [ ] `scripts/deploy/term/zsh` moved to `tools/term/zsh/deploy`
- [ ] `config/term/kitty/` moved to `tools/term/kitty/config/`
- [ ] `config/term/zsh/` moved to `tools/term/zsh/config/`
- [ ] `config/term/bats/` moved to `tools/term/bats/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config`
- [ ] Both install scripts call `$(dirname "$0")/deploy` at the end
- [ ] All cross-tool refs inside `tools/term/zsh/config/` updated to `$OROSHI_ROOT/tools/{domain}/{tool}/config/...` (notably: `RIPGREP_CONFIG_PATH`, nvim aliases, kitty aliases, deploy script calls in ZSH functions)
- [ ] `scripts/install/term/`, `scripts/deploy/term/`, and `config/term/` are empty and removed

## Blocked by

- issue-001 through issue-015 (cross-tool refs in ZSH configs target paths that must exist)
