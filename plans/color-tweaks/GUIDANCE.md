## Guidance

### Goal

Refactor the filetype group pipeline from a hand-written ZSH source + flat env vars into a
JSON source + build script + ZSH assoc array, consistent with how colors and projects work.

### Testing commands

```zsh
# Run build script
$OROSHI_ROOT/tools/term/zsh/config/theming/filetypes-build

# Run bats tests
bats tools/term/zsh/config/theming/__tests__/filetypes-build.bats
bats tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-load-definitions.bats
bats scripts/bin/zsh/zsh-lint/__tests__/rule-missing-filetypes-load.bats

# Run zsh-lint on updated files
zsh-lint tools/term/zsh/config/tools/ls.zsh
zsh-lint tools/term/zsh/config/functions/autoload/misc/filetype-group
zsh-lint tools/term/zsh/config/functions/autoload/img/img-display
zsh-lint tools/term/zsh/config/functions/autoload/fzf/fs/shared/fzf-fs-shared-preview-header
```

### Key file locations (relative to repo root)

| File | Role |
|------|------|
| `tools/term/zsh/config/theming/icons.zsh` | Add `filetype-*` icon section |
| `tools/term/zsh/config/theming/src/filetypes.json` | New JSON source (create) |
| `tools/term/zsh/config/theming/filetypes-build` | New build script (create) |
| `tools/term/zsh/config/theming/dist/filetypes.zsh` | Generated assoc array (create) |
| `tools/term/zsh/config/functions/autoload/filetypes/filetypes-load-definitions` | New autoload (create) |
| `scripts/bin/zsh/zsh-lint/__rules/rule-missing-filetypes-load.zsh` | New lint rule (create) |
| `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh` | Register lint rule |
| `tools/term/zsh/config/theming/index.zsh` | Remove eager source |
| `tools/term/zsh/config/tools/ls.zsh` | Consumer update |
| `tools/term/zsh/config/functions/autoload/misc/filetype-group` | Consumer update |
| `tools/term/zsh/config/functions/autoload/img/img-display` | Consumer update |
| `tools/term/zsh/config/functions/autoload/fzf/fs/shared/fzf-fs-shared-preview-header` | Consumer update |
| `tools/term/zsh/config/theming/src/filetypes-list.zsh` | Delete |
| `tools/term/zsh/config/theming/src/env-generate-filetypes` | Delete |
| `tools/term/zsh/config/theming/env/filetypes.zsh` | Delete |

### Conventions

- `FILETYPES[]` keys: lowercase, `:` separator (`FILETYPES[md:color]`, `FILETYPES[image:icon]`)
- Extension keys: derived from extension string, lowercased
- Filename keys: lowercased filename, dots converted to underscores (`.gitignore` → `_gitignore`)
- Group and extension names do not collide (verified by grep)
- `filetypes-load-definitions` guard: `((${#FILETYPES} > 0)) && return`
- Build script: ZSH, uses `jq` to parse JSON

### Prior art

| New file | Modelled after |
|----------|---------------|
| `src/filetypes.json` | `src/projects.json` |
| `filetypes-build` | `colors-build`, `projects-build` |
| `dist/filetypes.zsh` | `dist/colors.zsh`, `dist/projects.zsh` |
| `filetypes-load-definitions` | `colors-load-definitions`, `icons-load-definitions` |
| `rule-missing-filetypes-load.zsh` | `rule-missing-colors-load.zsh` |
| `filetypes-load-definitions.bats` | `colors-load-definitions.bats` |
| `rule-missing-filetypes-load.bats` | `rule-missing-colors-load.bats` |
| `filetypes-build.bats` | `colors-build.bats`, `projects-build.bats` |

## Discoveries

_Append findings here after each issue is completed._
