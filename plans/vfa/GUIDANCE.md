## Guidance

### Context

All fzf option/preview/source files under
`tools/term/zsh/config/functions/autoload/fzf/` previously used `$COLOR_ALIAS_*` and
`$COLOR_*` environment variables from a legacy theming system. These are now undefined.
The current system uses a `$COLORS` associative array populated by `colors-load-definitions`.

### Variable mapping rule

`COLOR_ALIAS_X` → `COLORS[x]` — lowercase, underscores become hyphens.
Basic colors: `COLOR_BLACK` → `COLORS[black]`, `COLOR_WHITE` → `COLORS[white]`,
`COLOR_GREEN` → `COLORS[green]`, `COLOR_GRAY_2` → `COLORS[gray-2]`.

### colors-load-definitions

Must be called before any `$COLORS[...]` access, after `setopt local_options err_return`.
Add alongside any existing `icons-load-definitions` call.

### colorize

Signature: `colorize "text" $COLORS[fg]` or `colorize "text" $COLORS[fg] $COLORS[bg]`.
`$COLORS[key]` holds a bare 256-color number — pass it directly to `colorize`.

### Reference implementation

`tools/term/zsh/config/functions/autoload/fzf/fs/shared/fzf-fs-shared-preview-header`
is already partially migrated and shows the correct pattern.

### Testing

- **Lint:** `zsh-lint <filepath>`
- **Manual:** open each affected picker and confirm prompt colors render correctly
- **No bats tests** for fzf option/preview/source files

### Out of scope

- `FILETYPE_${ext:u}_COLOR` dynamic variable pattern in `fzf-fs-shared-preview-header`
- Files already on `$COLORS[...]` (`fzf-fs-shared-options`, `fzf-fs-files-shared-options`,
  `fzf-fs-directories-shared-options`, `fzf.zsh`)

## Discoveries

<!-- Agents append findings here after each issue -->

### Issue 01 — fix-vfa-git-stageable-options

- Inline icon bytes (U+F440, `ef 91 80`) in fzf option files cannot be matched by the Edit tool — use `perl -0777 -i -pe` with `\xEF\x91\x80` hex escapes to replace them.
- New icon keys added to `icons.zsh` without a real glyph get `"x"` as placeholder value by user convention; the actual glyph must be filled in manually.
