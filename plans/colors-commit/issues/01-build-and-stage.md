## TLDR

Replace `colors-reload` with `colors-build-and-stage` in the commit pipeline so rebuilt dist files are auto-staged.

## What to build

1. Create `scripts/yarn/colors-build-and-stage` — ZSH script that:
   - Calls `colors-reload` (the global bin)
   - Then `git add`s the four dist directories:
     - `tools/term/zsh/config/theming/dist/`
     - `tools/cli/bat/config/dist/`
     - `tools/cli/rg/config/dist/`
     - `tools/git/git/config/dist/`

2. Update `package.json` scripts: replace `"colors-reload"` entry with `"colors-build-and-stage"` pointing to `./scripts/yarn/colors-build-and-stage`.

3. Update `lintstaged.config.js`: both theming glob patterns change from `yarn run colors-reload` to `yarn run colors-build-and-stage`.

4. Delete `scripts/yarn/filetypes-build` — dead code, nothing references `yarn run filetypes-build`.

## Acceptance criteria

- [ ] `scripts/yarn/colors-build-and-stage` exists and is executable
- [ ] `package.json` has `colors-build-and-stage` script, no `colors-reload` script
- [ ] Both lint-staged patterns call `yarn run colors-build-and-stage`
- [ ] `scripts/yarn/filetypes-build` is deleted
- [ ] Global `colors-reload` bin is unchanged
