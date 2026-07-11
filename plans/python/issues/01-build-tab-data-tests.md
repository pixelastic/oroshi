## TLDR

Extend `test_tab_data.py` with full behavioral coverage of `build_tab_data`.

## What to build

Add test cases to `tools/term/kitty/config/__tests__/test_tab_data.py` covering every branching path in `build_tab_data`. The function takes raw Kitty `TabBarData` + `DrawData` and returns a flat dict used by the rest of the pipeline. Tests mock `projects.get` and set `_icons` directly — no real file I/O.

## Behavioral Tests

**Guard**
- Returns `{}` when `tab` is falsy

**Basic fields**
- `id` matches `tab.tab_id`
- `name` matches `tab.title`
- `isActive` matches `tab.is_active`
- `isFullscreen` is true when `layout_name == "stack"`, false otherwise
- `defaultBg` and `separatorBg` are derived from `draw_data.default_bg`

**Title construction**
- Title is `" {icon}{name} "` when project has an icon
- Title is `"  {name} "` (double space) when project has no icon
- Attention icon appended to title when tab ID is in `tabState["attentionIds"]`
- Fullscreen icon appended (with trailing space) when `layout_name == "stack"`
- Both attention and fullscreen icons can appear together

**Active tab colors**
- `fg` uses `projectData["fg"]` when present
- `fg` falls back to `draw_data.active_fg` when project has no `fg`
- `bg` uses `projectData["bg"]` when present
- `bg` falls back to `draw_data.active_bg` when project has no `bg`

**Inactive tab colors**
- `bg` uses `projectData["bgInactive"]` when present
- `bg` falls back to `draw_data.inactive_bg` when project has no `bgInactive`
- `fg` uses `projectData["bg"]` when present
- `fg` falls back to `draw_data.inactive_fg` when project has no `bg`

**Separator**
- `separatorFg` equals `bg`
- `separatorBg` equals `defaultBg`

## Acceptance criteria

- [ ] All new tests pass (`python-test __tests__/test_tab_data.py`)
- [ ] No real file I/O — `projects.get` mocked, `_icons` set directly
- [ ] `tabState["attentionIds"]` reset in fixture
- [ ] Lint passes (`python-lint --fix __tests__/test_tab_data.py`)
