## Guidance

### Goal

Migrate all `compdef` completion functions from the old flat color variable system (`$COLOR_ALIAS_*`, `$COLOR_WHITE`, etc.) to the current associative array system (`$COLORS[key]`, `$ICONS[key]`), and wire up load-definitions calls.

### File locations

- Icon definitions: `tools/term/zsh/config/theming/icons.zsh`
- Color definitions: `tools/term/zsh/config/theming/dist/colors.zsh` (read-only reference — do not edit)
- Completion files: `tools/term/zsh/config/completion/compdef/_*`
- `completion-header` function: `tools/term/zsh/config/completion/styling.zsh`

### Conventions

- `completion-header <bgColor> <fgColor> <label>` — background color is a terminal 256-color index stored in `$COLORS[key]`
- Every completion function must call `colors-load-definitions` then `icons-load-definitions` as its first two statements
- Header label format: `" $ICONS[key] Label text "` (leading space, icon, space, text, trailing space)
- No hardcoded Nerd Font glyphs in header labels — always use `$ICONS[key]`
- New icon keys added in issue 01 use `X` as a placeholder glyph; do not replace them

### Testing

No automated tests. Verify by sourcing the file in zsh and triggering tab completion manually.

Lint command: `zsh-lint <filepath>`

### Color mapping reference

| Old variable | New key |
|---|---|
| `COLOR_ALIAS_GIT_WORKTREE` | `$COLORS[git-worktree]` |
| `COLOR_ALIAS_GIT_BRANCH` | `$COLORS[git-branch]` |
| `COLOR_ALIAS_GIT_TAG` | `$COLORS[git-tag]` |
| `COLOR_ALIAS_GIT_REMOTE` | `$COLORS[git-remote]` |
| `COLOR_ALIAS_GIT_SUBMODULE` | `$COLORS[git-submodule]` |
| `COLOR_ALIAS_GIT_MODIFIED` | `$COLORS[git-modified]` |
| `COLOR_ALIAS_DOCKER_IMAGE` | `$COLORS[docker-image]` |
| `COLOR_ALIAS_DOCKER_IMAGE_REMOTE` | `$COLORS[docker-image-remote]` |
| `COLOR_ALIAS_DOCKER_CONTAINER` | `$COLORS[docker-container]` |
| `COLOR_ALIAS_DOCKER_CONTAINER_RUNNING` | `$COLORS[docker-container-running]` |
| `COLOR_ALIAS_YARN_LINK_EXTERNAL` | `$COLORS[yarn-link-external]` |
| `COLOR_ALIAS_YARN_LINK_LOCAL` | `$COLORS[yarn-link-workspace]` |
| `COLOR_ALIAS_YARN_LINK_CLASSIC` | `$COLORS[yarn-link-classic]` |
| `COLOR_ALIAS_YARN_LINK_GLOBAL` | `$COLORS[yarn-package-global]` |
| `COLOR_ALIAS_YARN_PACKAGE_GLOBAL` | `$COLORS[yarn-package-global]` |
| `COLOR_ALIAS_LANGUAGE_JAVASCRIPT` | `$COLORS[language-javascript]` |
| `COLOR_ALIAS_LANGUAGE_PYTHON` | `$COLORS[language-python]` |
| `COLOR_ALIAS_LANGUAGE_NODE` | `$COLORS[language-node]` |
| `COLOR_ALIAS_LANGUAGE_BATS` | `$COLORS[language-bats]` |
| `COLOR_ALIAS_AI` | `$COLORS[ai]` |
| `COLOR_ALIAS_DIRECTORY` | `$COLORS[directory]` |
| `COLOR_ALIAS_FLAG` | `$COLORS[flag]` |
| `COLOR_ALIAS_VIDEO_STREAM_AUDIO` | `$COLORS[video-stream-audio]` |
| `COLOR_WHITE` | `$COLORS[white]` |
| `COLOR_BLACK` | `$COLORS[black]` |
| `COLOR_GRAY_2` | `$COLORS[gray-2]` |

## Discoveries

### Issue 01 — Add placeholder icon keys
- `icons.zsh` is the definitions file itself — adding `icons-load-definitions` to it would cause infinite recursion (the function sources this file, and the guard `((${#ICONS} > 0))` won't trigger mid-load). Use `# zsh-lint disable=missingIconsLoad` on the line above the first `ICONS[` assignment instead.
- `icons.zsh` has invisible Nerd Font glyphs as values — Edit tool matches fail if the match string includes those values. Match on comment lines or key names only (never include the value in old_string).
- Icon key naming follows the shortest descriptive form: `bats` not `language-bats` (matches `python`, `ruby` pattern).
