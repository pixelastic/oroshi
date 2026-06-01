## Issue 02 — to-issues test fields

### Standards: label case inconsistency in Step 3

```
- **scaffolding-test**: prose description (omit line if field absent)
- **permanent-test**: prose description (omit line if field absent)
```

**Problem:** Existing Step 3 fields use title-case (`Title`, `Type`, `Blocked by`). New fields use lowercase-hyphenated names.

**Reason skipped:** The field names must match the actual field names in the issue template (`scaffolding-test`, `permanent-test`). Case consistency with unrelated display labels is not worth diverging from the canonical field names.

---

## Issue 01 — tdd/scaffolding doc

### Checklist scope: "before writing this test" vs "before writing any test"

```
[ ] Declare test type (permanent / scaffolding) before writing this test
```

**Problem:** Spec says "Declared test strategy… before writing any test" (plan-level declaration). Implementation uses "before writing this test" (per-test declaration).

**Reason skipped:** User explicitly refined the spec to per-test classification ("c'est une question individuelle de est-ce que pour ça c'est des scaffold test ou est-ce que c'est des permanent test"). The per-test framing is intentional.
