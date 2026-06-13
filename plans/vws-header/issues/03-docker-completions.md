## TLDR

Migrate all 8 docker `compdef` completion functions to use `$COLORS[key]` and `$ICONS[key]`, and add the two load-definitions calls.

## What to build

Update these files under `tools/term/zsh/config/completion/compdef/`:
`_docker-images-local-ids`, `_docker-images-local-names`, `_docker-images-local-with-tags`, `_docker-images-local-with-tags-without-github`, `_docker-images-remote`, `_docker-containers-running`, `_docker-containers-ids`, `_docker-containers`

For each file:
1. Add `colors-load-definitions` and `icons-load-definitions` as the first two statements inside the function body.
2. Replace `$COLOR_ALIAS_*` with `$COLORS[key]` and `$COLOR_WHITE`/`$COLOR_BLACK` with `$COLORS[white]`/`$COLORS[black]`.
3. Add a `$ICONS[key]` reference to header labels that currently have none.

Color mappings for this group:
- `COLOR_ALIAS_DOCKER_IMAGE` → `$COLORS[docker-image]`
- `COLOR_ALIAS_DOCKER_IMAGE_REMOTE` → `$COLORS[docker-image-remote]`
- `COLOR_ALIAS_DOCKER_CONTAINER` → `$COLORS[docker-container]`
- `COLOR_ALIAS_DOCKER_CONTAINER_RUNNING` → `$COLORS[docker-container-running]`

Icon mappings for this group:
- `_docker-images-*` → `$ICONS[docker-image]` (new key from issue 01)
- `_docker-containers-running` → already uses `$ICONS[docker-run]`
- `_docker-containers-ids` / `_docker-containers` → already use `$ICONS[docker-stop]`

## Acceptance criteria

- [ ] All 8 files have `colors-load-definitions` + `icons-load-definitions` as the first two function statements
- [ ] No `$COLOR_ALIAS_*`, `$COLOR_WHITE`, or `$COLOR_BLACK` references remain
- [ ] All header labels include a `$ICONS[key]` reference
- [ ] `zsh-lint` passes on all 8 files
