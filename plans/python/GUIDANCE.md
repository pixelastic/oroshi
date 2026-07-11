## Guidance

### Context

This plan refactors the Kitty tab bar's Redraw and Reload mechanics. See `PRD.md` for full design rationale and `tools/term/kitty/config/GLOSSARY.md` for domain vocabulary.

### Repo layout

- Python tab bar entry point: `tools/term/kitty/config/tab_bar.py`
- Tab bar lib modules: `tools/term/kitty/config/lib/`
- Python tests: `tools/term/kitty/config/__tests__/`
- CLI scripts: `scripts/bin/kitty/`
- CLI bats tests: `scripts/bin/kitty/__tests__/`
- Keybindings: `tools/term/kitty/config/keybindings.conf`
- Glossary: `tools/term/kitty/config/GLOSSARY.md`

### Testing commands

```
# Python tests (run from tools/term/kitty/config/)
yarn run test __tests__/test_<name>.py

# Bats tests
bats scripts/bin/kitty/__tests__/<name>.bats
```

### Key paths (runtime)

- Attention File: `$OROSHI_TMP_FOLDER/kitty/attention`
- Redraw Beacon: `$OROSHI_TMP_FOLDER/kitty/beacons/redraw`
- Reload Beacon: `$OROSHI_TMP_FOLDER/kitty/beacons/reload`

### Conventions

- Beacon files: presence-only signals, no content — live under `kitty/beacons/`
- State files: contain data (e.g. tab IDs) — live at `kitty/` root
- Python I/O: always in explicit `init()` functions, never at module level
- `check()` functions: always no-op if beacon absent (one `os.path.exists` call, no further I/O)
- Dynamic module discovery for reload: `[m for m in sys.modules if m.startswith("lib.")]`
- Reload order in `first_pass()`: `reload.check()` before `redraw.check()`

### Prior art

- `test_projects.py` — reference pattern for Python unit tests (mock I/O, fixture for state reset)
- `kitty-redraw.bats` — reference pattern for CLI bats tests (mock `kitty`, check args)
- `kitty-tab-attention-add.bats` — reference for beacon file creation tests

### Statusbar

`statusbar.py` is intentionally left untouched and simply not imported. It will be re-introduced as an independent feature later. Do not modify it.

## Discoveries

<!-- Append non-trivial findings here after each issue, format: -->
<!-- ### Issue XX — short title -->
<!-- - finding -->
