## Issue 03 — Update grill-me

### "Quick implementation" lacks a named skill reference

```md
1. Write a glossary
2. Write a PRD
3. Quick implementation
```

**Problem:** Standards reviewer flagged that post-grill handoffs in `to-prd/SKILL.md` name target skills explicitly; option 3 has no skill reference.

**Reason skipped:** Spec says "No explicit instruction to invoke the `glossary` skill by name — the skill is expected to know what to do." This intentional omission applies to all three options, not just glossary.

### No follow-through instruction after the option list

**Problem:** Spec reviewer flagged that nothing tells the model to act on the chosen option after presenting the menu.

**Reason skipped:** Intentional per spec design — "the skill is expected to know what to do."

---

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
