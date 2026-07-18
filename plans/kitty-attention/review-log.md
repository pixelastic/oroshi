## Issue 01 — kitty-tab-switch
### Missing inline comment on usage line
```zsh
# $ kitty-tab-switch {tabId}
```
**Problem:** Header usage line lacks an inline `# comment` per zsh-writer template.
**Reason skipped:** Script is a one-liner; the description line already explains the purpose. Adding a redundant comment would be noise.

## Issue 05 — debug attention autoclear
### Hardcoded paths in REDRAW_BEACON / ATTENTION_FILE
```python
REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"
```
**Problem:** Paths should use `$OROSHI_TMP_FOLDER` env var instead of hardcoded `/home/tim/local/tmp/oroshi`.
**Reason skipped:** Pre-existing — these constants existed before this issue and are not introduced by the diff.

### Spec: debug logging not present in final diff
**Problem:** Spec asked for append-only debug logging; final diff has none.
**Reason skipped:** Debugging was done interactively during the session. Logging was added, root cause identified, then removed and replaced with a fix. The HITL workflow was followed in conversation, not in the final artifact.

### Spec: _on_attention_clear replaced instead of instrumented
**Problem:** Spec expected the existing callback to be preserved and observed.
**Reason skipped:** The callback was instrumented during debugging, then replaced with a poll-based approach as the fix. Issue 06 (fix) was effectively folded into issue 05.
