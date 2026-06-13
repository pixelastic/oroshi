## TLDR

Add 9 placeholder icon keys to `icons.zsh` so completion files can reference them without broken `$ICONS[key]` expansions.

## What to build

Add 9 new entries to the Git section and relevant sections of `tools/term/zsh/config/theming/icons.zsh`, each with the literal value `X` as a placeholder glyph. The keys are:

- `docker-image` — for Docker image completion headers
- `flag` — for flag/option completion headers
- `jump` — for jump-bookmark completion headers
- `language-bats` — for bats test completion headers (replaces a hardcoded glyph)
- `make` — for Makefile target completion headers
- `plan` — for plan completion headers
- `skill` — for skill completion headers
- `ssh` — for SSH host completion headers
- `video-stream-audio` — for audio stream completion headers

Group new keys near semantically related existing keys (e.g. `docker-image` near `docker-run`, `language-bats` near `python`).

## Acceptance criteria

- [ ] All 9 new keys exist in `icons.zsh` with value `X`
- [ ] Each key is placed in a semantically appropriate section
- [ ] No existing keys are modified or removed
- [ ] `zsh-lint` passes on `icons.zsh`
