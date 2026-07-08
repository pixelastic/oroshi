## Issue 02 — attention in tabState

### camelCase local variables in tab_data.py
```python
defaultBg = as_rgb(int(draw_data.default_bg))
isFullscreen = tab.layout_name == "stack"
isActive = tab.is_active
projectData = get_project_data(name)
isAttention = str(id) in tabState["attentionIds"]
tabData = { ... }
```
**Problem:** Reviewer flagged camelCase locals violate PEP 8 / python-writer style.
**Reason skipped:** Pre-existing convention in the deleted `parseRawTabData.py`; carried over unchanged. `python-lint --fix` passed cleanly, meaning the linter config accepts this. Renaming would be a separate refactor beyond the scope of this issue.

### Return-early pattern in tab_data.py
```python
if isActive:
    ...
    tabData["fg"] = projectData.get("fg", defaultActiveFg)
    tabData["bg"] = projectData.get("bg", defaultActiveBg)
else:
    ...
    tabData["bg"] = projectData.get("bgInactive", defaultInactiveBg)
    tabData["fg"] = projectData.get("bg", defaultInactiveFg)
```
**Problem:** python-writer style says "no avoidable nesting"; reviewer flagged this as two branches that could be early-return.
**Reason skipped:** Pre-existing structure from original file. Both branches assign multiple keys to `tabData`, making return-early non-trivial. Out of scope for this renaming issue.

### Hardcoded absolute paths
```python
_ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"
_ICONS_PATH = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/icons.json"
```
**Problem:** Memory feedback requires `$OROSHI_ROOT` env var, not hardcoded paths.
**Reason skipped:** Pre-existing in original files, not introduced by this diff. Tracked as a systemic issue across the codebase; fixing it belongs in a dedicated issue.

### Behavioral acceptance criteria not verified
**Problem:** Spec requires verifying attention icon appears/clears and `kitty-tab-bar-reload` works without error.
**Reason skipped:** Per GUIDANCE.md, no Python test runner exists. Verification is manual: "Verify by reloading Kitty's tab bar." Cannot be automated.
