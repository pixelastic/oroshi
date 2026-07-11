## Issue 03 — Reload beacon

### Hardcoded path vs env var

**Problem:** Standards reviewer flagged `RELOAD_BEACON = "/home/tim/local/tmp/oroshi/..."` as a hardcoded path; suggested using `OROSHI_TMP_FOLDER` env var.
**Reason skipped:** Kitty's Python runtime does not have shell env vars. Hardcoded path matches `redraw.py` exactly. Tests patch the constant directly via `mocker.patch.object`.

### Mock setup inside each @test, not in setup()

**Problem:** Standards reviewer flagged that `kitty-redraw() { :; }` + `bats_mock kitty-redraw` is repeated in each test body rather than extracted to `setup()`.
**Reason skipped:** `kitty-tab-attention-add.bats` (the reference pattern) does the same — mocks are defined inline per test to allow per-test behavior variation.

### Filesystem sentinel to verify kitty-redraw was called

**Problem:** Standards reviewer flagged `touch "$BATS_TMP_DIR/redraw-called"` inside the mock function as a filesystem side-effect pattern.
**Reason skipped:** Same pattern used in `kitty-tab-attention-add.bats` reference pattern (`kitty-redraw() { touch "$BATS_TMP_DIR/redraw-called"; }`).

### `local` at script level

**Problem:** Both reviewers noted `local beaconDir` at script scope (not inside a function) is technically incorrect.
**Reason skipped:** Matches the existing `kitty-redraw` script pattern exactly (`local beaconDir="$OROSHI_TMP_FOLDER/kitty/beacons"`).

### Scaffolding test not in test_reload.py

**Problem:** Spec acceptance criteria says `test_reload.py` should contain "all behavioral and scaffolding tests". Scaffolding test is in `plans/python/scaffold/03-reload-beacon.bats` instead.
**Reason skipped:** Ralph instructions explicitly route scaffolding tests to `plans/<slug>/scaffold/`. The acceptance criteria wording is loose. Test exists and passes.

## Issue 02 — Redraw beacon

### Autouse fixtures should be in conftest.py

```python
@pytest.fixture(autouse=True)
def reset_state():
    tabState["attentionIds"] = set()
    yield

@pytest.fixture(autouse=True)
def patch_paths(mocker, tmp_path):
    ...
```
**Problem:** Reviewer flagged that autouse fixtures should live in conftest.py.
**Reason skipped:** These fixtures are only used by `test_redraw.py`. Existing test files (e.g. `test_projects.py`) also keep their fixtures in-file. conftest.py is for cross-file sharing only.

### Module-level env reads for constants

```python
REDRAW_BEACON = os.path.join(os.environ.get("OROSHI_TMP_FOLDER", ""), "kitty/beacons/redraw")
ATTENTION_FILE = os.path.join(os.environ.get("OROSHI_TMP_FOLDER", ""), "kitty/attention")
```
**Problem:** Constants evaluated at import time; reviewer suggested deferring to function or init().
**Reason skipped:** `mocker.patch.object` correctly overrides module-level attributes in tests. The env var is available at Kitty startup. No functional issue.

### New bats tests don't re-assert set-tab-color call

```bash
@test "success: creates beacon at correct path" { ... }
@test "success: creates beacon before calling kitty" { ... }
```
**Problem:** Spec says "`kitty @ set-tab-color --match all active_bg=NONE` is still called"; new tests don't assert this.
**Reason skipped:** Existing test `"success: calls kitty set-tab-color with --match all active_bg=NONE"` already covers this. New tests focus narrowly on beacon behavior.
