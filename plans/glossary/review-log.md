## Issue 02 — Migrate files

### hooks/GLOSSARY.md does not conform to GLOSSARY-FORMAT.md template

```md
# Glossary — preToolUse Bash Hook

## Decision layers

...

### Layer 1 — Solkan

| Term | Meaning |
|------|---------|
| **allow** | Command is in the allowlist — safe to execute without user input |
```

**Problem:** File is missing `## Language` section, uses table-format terms instead of block format (`**Term**:\nDef\n_Avoid_:`), and has no `_Avoid_` lists on any term. All three are required by `GLOSSARY-FORMAT.md`.

**Reason skipped:** The issue spec explicitly says "content unchanged" for this migration. Reformatting is out of scope for issue 02 — should be addressed in a separate issue.
