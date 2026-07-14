## Guidance

- Testing zsh: `bats <filepath>`
- Linting zsh: `zsh-lint <filepath>`
- Linting bats: `bats-lint <filepath>`
- Tests live in `__tests__` directories adjacent to the code they test
- Autoload functions use `setopt local_options err_return` for error handling
- Autoload functions live in `tools/term/zsh/config/functions/autoload/<domain>/`
- fzf preview dispatcher: `scripts/bin/fzf/__lib/fzf-fs-preview.zsh`
- fzf preview tests: `scripts/bin/fzf/__lib/__tests__/fzf-fs-preview.bats`
- Existing video utilities: `tools/term/zsh/config/functions/autoload/video/` (video-duration, video-dimensions, etc.)
- Cache location: `$OROSHI_TMP_FOLDER/fzf/previews/`
- `file-hash` callers: `fzf-fs-preview.zsh` (line 169), `notion-icon-auto` (line 36)
- Reference pattern: `pdf-cover-extract` → `img-display --fzf-preview` pipeline
- Use `zsh-writer` skill for writing ZSH code

## Discoveries

### Issue 03 — video-thumbnail
- ffmpeg/ffprobe flags (`-v`, `-i`, `-vf`, `-y`) have no GNU-style long-form equivalents — short flags are canonical for these tools
- `zshlint` enforces `[[ ! condition ]] && return` over `[[ condition ]] || return` (`noOrGuard` rule)
