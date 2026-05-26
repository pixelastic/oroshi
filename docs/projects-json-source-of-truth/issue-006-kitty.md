## PRD

[projects-json-source-of-truth/PRD.md](./PRD.md)

## What to build

Update Kitty's `tab_bar_modules/projects.py` to read from `dist/projects.json` in the new nested format instead of the current flat `PROJECT_*` key format.

Currently `projects.py` scans for keys ending in `_NAME` to find project names, then reconstructs sibling keys (`{PREFIX}_ICON`, `{PREFIX}_BACKGROUND`, etc.). In the new format, project names are top-level keys and color/icon data is nested under them.

The one-time load at Kitty startup (`initProjectList()`) and the cached dict lookup at render time (`getProjectData(tab.title)`) are preserved — only the parsing logic changes. The path to the JSON file changes from `env/projects.json` to `dist/projects.json`. Color fields are accessed as `project["background"]["ansi"]` instead of `PROJECT_NAME_BACKGROUND`.

## Acceptance criteria

- [ ] Kitty tab bar shows correct project background color for a registered project
- [ ] Kitty tab bar shows correct inactive background color for tabs not in focus
- [ ] Kitty tab bar shows correct foreground color and icon
- [ ] `initProjectList()` reads from `dist/projects.json` (not `env/projects.json`)
- [ ] No `PROJECT_*` flat key parsing remains in `projects.py`
- [ ] Kitty refresh beacon mechanism continues to work (reloads data on demand)

## Blocked by

- [issue-002-projects-build.md](./issue-002-projects-build.md) — `dist/projects.json` must exist in the new nested format
