## Issue 01 — Skill instructions
### Clipboard refresh explicitness
```markdown
If the user requests changes, edit the draft, then re-run Steps 5-6.
```
**Problem:** Spec AC says "post-edit clipboard refresh" but no explicit clipboard mention in the loop instruction.
**Reason skipped:** `slack-writer-end` (called in Step 6) already handles clipboard copy. Re-running Steps 5-6 implicitly refreshes clipboard. Adding explicit mention would be redundant.
