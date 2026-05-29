## TLDR

Migrate the Kitty tab bar Python module to read `dist/projects.json` instead of `env/projects.json`.

## What to build

`tab_bar_modules/projects.py` in the Kitty config currently reads `env/projects.json` — a flat dict of `PROJECT_<KEY>_NAME`, `PROJECT_<KEY>_ICON`, etc. — and reconstructs a per-project structure through string heuristics (`_NAME` suffix detection, prefix stripping).

Replace `initProjectList()` with a direct iteration over `dist/projects.json`, which is a nested dict keyed by project name. For each project entry:
- Read `icon` directly (optional — skip if absent).
- Read `background.ansi`, `backgroundInactive.ansi`, `foreground.ansi` as integers and pass to `getCursorColor()` (which already accepts an int).
- Skip the `_NAME`-suffix heuristics entirely — they are an artefact of the flat format.

Update the hardcoded JSON path to point to `dist/projects.json`.

No test changes needed.

## Acceptance criteria

- [ ] `initProjectList()` reads from `dist/projects.json`
- [ ] `initProjectList()` no longer parses `_NAME`-suffix keys or builds prefix strings
- [ ] Project icons and colors render correctly in the Kitty tab bar
- [ ] No reference to `env/projects.json` remains in the Kitty config
