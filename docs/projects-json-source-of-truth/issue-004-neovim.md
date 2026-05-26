## PRD

[projects-json-source-of-truth/PRD.md](./PRD.md)

## What to build

Three related NeoVim changes delivered as one slice:

**1. `F.readJson()` helper** — a new function in the NeoVim functions module that takes an absolute file path, reads it, and returns a parsed Lua table via `vim.fn.json_decode`. Returns `nil` if the file does not exist or cannot be parsed.

**2. `M.getProjectData()` migration** — update `highlight.lua` to read project metadata from `dist/projects.json` via `F.readJson()` instead of calling the `project-key` shell command and reading `PROJECT_*` environment variables. The per-project cache in `O.projects` is preserved — data is loaded once per project name and reused. Attribute access changes from flat env var lookup to nested table navigation (e.g. `data[projectName].background.ansi`).

**3. NeoVim autocommand** — a new `BufWritePost` autocmd matching `src/projects.json`. On fire: runs `src/projects-build` asynchronously via `vim.fn.jobstart`. After the job completes, runs `:checktime` so NeoVim reloads any open dist files without a manual prompt.

## Acceptance criteria

- [ ] `F.readJson(path)` returns a Lua table for a valid JSON file
- [ ] `F.readJson(path)` returns `nil` for a missing file
- [ ] NeoVim statusline shows correct project background color after opening a file inside a registered project
- [ ] `M.getProjectData()` no longer calls `project-key` or reads `PROJECT_*` env vars
- [ ] Per-project data is cached — `F.readJson()` is not called on every statusline render
- [ ] Saving `src/projects.json` in NeoVim triggers `src/projects-build` automatically
- [ ] After the build completes, `dist/projects.json` is updated without a manual reload prompt

## Blocked by

- [issue-002-projects-build.md](./issue-002-projects-build.md) — `dist/projects.json` must exist for `M.getProjectData()` to read from
