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

<!-- Append non-trivial findings here after each issue, format: -->
<!-- ### Issue XX — short title -->
<!-- - finding -->

### Issue 03 — Reload beacon
- Python module-level path constants use hardcoded paths (same as `redraw.py`) — Kitty's Python runtime may not have shell env vars; patching works fine in tests via `mocker.patch.object`.
- `python-test` (not `yarn run test`) is the correct command for Python tests; run from repo root with full path to test file.
- Scaffolding tests (checking code structure/ordering) live in `plans/<slug>/scaffold/<issue>.bats`, not in `__tests__/`.

### Issue 02 — Redraw beacon
- `mocker.patch.object(module, "CONSTANT", value)` works for patching module-level string constants in pytest; no need to move env reads into `check()`.
- zsh-lint `noExternalBasename` rule: use `${var:h}` instead of `$(dirname "$var")`.
- Autouse fixtures for a single test file can live in the test file itself (not conftest.py); conftest.py is for cross-file sharing only.
