## TLDR

Insert `icons-build` into `colors-refresh` before `filetypes-build`, and extend the lint-staged glob to watch `icons.jsonc` and `icons-build`.

## What to build

In `scripts/bin/colors-refresh`, insert `icons-build` between the `colors-build` and `filetypes-build` calls. `filetypes-build` calls `icons-load-definitions` which sources `dist/icons.zsh`, so `icons-build` must run first.

In `lintstaged.config.js`, extend the existing glob that triggers `colors-refresh` to also match changes to `icons.jsonc` and `icons-build`.

## Acceptance criteria

- [ ] `colors-refresh` calls `icons-build` before `filetypes-build`
- [ ] `lintstaged.config.js` glob includes `icons.jsonc` and `icons-build`
