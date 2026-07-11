## Guidance

### Context

This plan adds test coverage for the core kitty tab bar rendering pipeline. No production code changes — tests only. See `PRD.md` for scope and rationale.

### Repo layout

- Python tab bar entry point: `tools/term/kitty/config/tab_bar.py`
- Tab bar lib modules: `tools/term/kitty/config/lib/`
- Python tests: `tools/term/kitty/config/__tests__/`
- Shared state: `lib/state.py` — `tabState` dict

### Test files

- `__tests__/test_tab_data.py` — extend with `build_tab_data` cases (issue 01)
- `__tests__/test_pick_tabs.py` — create new (issue 02)
- `__tests__/test_tabs_first_pass.py` — create new (issue 03)
- `__tests__/test_tabs_second_pass.py` — create new (issue 04)

### Testing commands

```
# Run a single test file (from repo root)
python-test tools/term/kitty/config/__tests__/test_<name>.py

# Lint
python-lint --fix tools/term/kitty/config/__tests__/test_<name>.py
```

### Conventions

- All tests use `pytest` + `pytest-mock`
- `tabState` must be reset in a `setup()` fixture — import from `lib.state`
- Kitty types (`Screen`, `TabBarData`, `DrawData`, `ExtraData`) are always `MagicMock`
- Collaborators mocked via `mocker.patch("lib.module.collaborator")`
- Module-level constants mocked via `mocker.patch.object(module, "CONSTANT", value)`
- Autouse fixtures belong in the test file, not `conftest.py` (unless shared cross-file)

### Prior art (reference patterns)

- `test_projects.py` — state reset fixture, mock I/O
- `test_redraw.py` — patching module constants, autouse fixtures
- `test_tab_data.py` — mocking `_read_json`, setting module-level `_icons` directly

### Statusbar

`statusbar.py` is unused — do not add tests for it and do not import it.

## Discoveries

### Issue 01 — build_tab_data tests
- Spec said `"  {name} "` (double space) for no-icon titles, but code does `f" {icon}{name} "` — single space. Tests must assert actual code behavior, not spec wording.
- Production code does `str(id) in tabState["attentionIds"]`, so attention set entries must be strings (`{"1"}` for tab_id=1).
- Patch `lib.tab_data.as_rgb` with `side_effect=lambda x: x` to get predictable color values from integer draw_data attributes.

<!-- Append non-trivial findings here after each issue, format: -->
<!-- ### Issue XX — short title -->
<!-- - finding -->

### Issue 03 — Reload beacon
- Python module-level path constants use hardcoded paths (same as `redraw.py`) — Kitty's Python runtime may not have shell env vars; patching works fine in tests via `mocker.patch.object`.
- `python-test` (not `yarn run test`) is the correct command for Python tests; run from repo root with full path to test file.
- Scaffolding tests (checking code structure/ordering) live in `plans/<slug>/scaffold/<issue>.bats`, not in `__tests__/`.

### Issue 02 — pick_tabs tests
- `pick_tabs_to_display` enforces a minimum budget of 50 chars (`max(screen-statusbar, 50)`), so overflow tests need tab widths > 50 or enough tabs that total > 50; titles like `"X"*52` (width 53) work cleanly.
- The budget loop uses `break` (not `continue`) on the first tab that doesn't fit — a NARROW tab later in the priority list is silently excluded; tests for this need to assert on exact content, not just length.
- `import pytest` is required even when the only usage is `@pytest.fixture`; linters may flag it as unused but the decorator reference is real.

### Issue 02 — Redraw beacon
- `mocker.patch.object(module, "CONSTANT", value)` works for patching module-level string constants in pytest; no need to move env reads into `check()`.
- zsh-lint `noExternalBasename` rule: use `${var:h}` instead of `$(dirname "$var")`.
- Autouse fixtures for a single test file can live in the test file itself (not conftest.py); conftest.py is for cross-file sharing only.
