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

### Issue 02 — bulk-color-variable-substitution

- `icons.zsh` also contains binary glyph bytes in values — Edit tool fails; use `perl -0777 -pi -e` with regex matching only the ASCII key name (e.g. `s/(ICONS\[fzf-selected\]="[^"]*"\n)/.../`).
- In perl `-e` double-quoted strings, `"${COLORS[$k]}"` is interpreted as Perl array deref (→ empty string). Use string concatenation instead: `'${COLORS[' . $k . ']}'` and `'$COLORS[' . $k . ']'`.
- `ICONS[bats]` already has a trailing space in its value; when replacing the inline glyph, match glyph+one-space (`\xf3\xb0\xad\x9f\x20`) to avoid double-spacing.
- For preview files with no `setopt local_options err_return`, add it before `colors-load-definitions` (lint `missingErrReturn` will fire otherwise).
- Lint rule 2178 fires when an array variable is later reassigned a string; fix by introducing a new `local` variable for the string form.

### Issue 03 — colorize-refactor-apt-source-generate

- When a perl `s///` replacement string must contain `$COLORS[key]`, use a `q{}` variable: `my $r = q{$(colorize "..." $COLORS[key])}; s/pattern/$r/g`. Direct interpolation fails because perl parses `$COLORS[key]` as an array subscript, causing a version-format error.
