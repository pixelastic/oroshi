## TLDR

Convert the static `icons.zsh` into a nested JSONC source file and delete the original.

## What to build

Create `tools/term/zsh/config/theming/src/icons.jsonc` by migrating all entries from the existing static `tools/term/zsh/config/theming/icons.zsh`. Organize the entries into nested objects by category (e.g. all git icons under a `"git"` key, all docker icons under `"docker"`, etc.). Preserve the existing comment blocks as JSONC `//` comments.

Once the content is fully migrated, delete the static `icons.zsh`.

At this point `icons-load-definitions` is temporarily broken (it still sources the deleted file). That is expected and resolved in Issue 02.

## Acceptance criteria

- [ ] `src/icons.jsonc` exists and contains all ~150 entries from the original `icons.zsh`
- [ ] Entries are organized into nested groups matching the original comment sections
- [ ] All leaf values are the raw glyph strings (no transformation)
- [ ] Static `tools/term/zsh/config/theming/icons.zsh` is deleted
