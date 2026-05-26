## PRD

[projects-json-source-of-truth/PRD.md](./PRD.md)

## What to build

Update `theming/index.zsh` to source `dist/projects.zsh` (the new ZSH associative array) instead of `env/projects.zsh` (the old flat exports). If `dist/projects.zsh` does not exist at startup, run `src/projects-build` first to generate it.

This mirrors the existing pattern already used in `theming/index.zsh` for the colors and filetypes pipelines: generate if missing, then source.

The old `env/projects.zsh` sourcing line is removed. The `PROJECTS` associative array becomes available in the shell after startup instead of the 1274 flat `PROJECT_*` variables.

Note: ZSH project functions (`context-project`, `context-badge`, etc.) still read from `env/projects.zsh` and env vars — they are not changed here. This issue only wires up the new array into the shell environment, ready for the ZSH functions PRD.

## Acceptance criteria

- [ ] After a new shell starts, `$PROJECTS[oroshi.background.ansi]` returns the correct ANSI color code
- [ ] After a new shell starts, `$PROJECTS[aberlaas.path]` returns the correct tilde path with trailing slash
- [ ] If `dist/projects.zsh` is deleted, the next shell startup regenerates it automatically before sourcing
- [ ] The 1274 `PROJECT_*` env vars are no longer exported by this path (env/projects.zsh sourcing is removed)
- [ ] Existing shell functions that still read `env/projects.zsh` env vars continue to work (old pipeline untouched)

## Blocked by

- [issue-002-projects-build.md](./issue-002-projects-build.md) — `src/projects-build` must exist to generate `dist/projects.zsh`
