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
