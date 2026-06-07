## TLDR

Update `colors-refresh` to use `colors-build`, and delete all legacy files once every consumer is migrated.

## What to build

Update `scripts/bin/colors-refresh`:
- Replace the `env-generate-colors` call with `colors-build`
- Replace `source env/colors.zsh` with `source dist/colors.zsh` (both relative to the theming directory)
- `projects-build` call and everything after it remain in the same order

Delete legacy files:
- `tools/term/zsh/config/theming/src/env-generate-colors`
- `tools/term/zsh/config/theming/env/colors.zsh`

The final orchestration order in `colors-refresh`:
1. `kitty-refresh`
2. `colors-build`
3. `source dist/colors.zsh`
4. `env-generate-filetypes` + `source dist/filetypes.zsh`
5. `projects-build`
6. `projects-load-definitions`
7. `generate-theme` (bat)
8. `generate-config` (rg)
9. `generate-config` (git)

## Acceptance criteria

- [ ] `colors-refresh` calls `colors-build` (not `env-generate-colors`)
- [ ] `colors-refresh` sources `dist/colors.zsh` (not `env/colors.zsh`)
- [ ] `src/env-generate-colors` deleted
- [ ] `env/colors.zsh` deleted
- [ ] Running `colors-refresh` completes without errors (manual verification)
- [ ] No `COLOR_*` variables appear in `env` output after a fresh shell session (manual verification)
