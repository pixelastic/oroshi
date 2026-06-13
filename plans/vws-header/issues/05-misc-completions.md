## TLDR

Migrate the remaining 9 misc `compdef` completion functions to use `$COLORS[key]` and `$ICONS[key]`, and add the two load-definitions calls.

## What to build

Update these files under `tools/term/zsh/config/completion/compdef/`:
`_pip-packages`, `_make-targets`, `_ssh-known-hosts`, `_jumps`, `_skills`, `_plans`, `_bats-test`, `_image-resize`, `_video-streams-audio`

For each file:
1. Add `colors-load-definitions` and `icons-load-definitions` as the first two statements inside the function body.
2. Replace `$COLOR_ALIAS_*` with `$COLORS[key]` and `$COLOR_WHITE`/`$COLOR_BLACK`/`$COLOR_GRAY_2` with `$COLORS[white]`/`$COLORS[black]`/`$COLORS[gray-2]`.
3. Replace any hardcoded Nerd Font glyphs with `$ICONS[key]` references.
4. Add a `$ICONS[key]` reference to header labels that currently have none.

Color mappings for this group:
- `COLOR_ALIAS_LANGUAGE_PYTHON` → `$COLORS[language-python]`
- `COLOR_ALIAS_LANGUAGE_JAVASCRIPT` → `$COLORS[language-javascript]` (used by `_make-targets`)
- `COLOR_ALIAS_LANGUAGE_BATS` → `$COLORS[language-bats]`
- `COLOR_ALIAS_AI` → `$COLORS[ai]`
- `COLOR_ALIAS_DIRECTORY` → `$COLORS[directory]` (used by `_jumps` and `_ssh-known-hosts`)
- `COLOR_ALIAS_FLAG` → `$COLORS[flag]`
- `COLOR_ALIAS_VIDEO_STREAM_AUDIO` → `$COLORS[video-stream-audio]`
- `COLOR_GRAY_2` → `$COLORS[gray-2]`

Icon mappings for this group (all new keys from issue 01):
- `_pip-packages` → `$ICONS[python]`
- `_make-targets` → `$ICONS[make]`
- `_ssh-known-hosts` → `$ICONS[ssh]`
- `_jumps` → `$ICONS[jump]`
- `_skills` → `$ICONS[skill]`
- `_plans` → `$ICONS[plan]`
- `_bats-test` → hardcoded glyph → `$ICONS[language-bats]`
- `_image-resize` → `$ICONS[flag]`
- `_video-streams-audio` → `$ICONS[video-stream-audio]`

## Acceptance criteria

- [ ] All 9 files have `colors-load-definitions` + `icons-load-definitions` as the first two function statements
- [ ] No `$COLOR_ALIAS_*`, `$COLOR_WHITE`, `$COLOR_BLACK`, or `$COLOR_GRAY_2` references remain
- [ ] No hardcoded Nerd Font glyphs remain in header labels
- [ ] All header labels include a `$ICONS[key]` reference
- [ ] `zsh-lint` passes on all 9 files
