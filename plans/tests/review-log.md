## Issue 03 — ralph scaffold routing

### Spec: scaffold filename uses full slug vs number-only

```
- Scaffolding tests → `plans/<slug>/scaffold/<issue-filename>.bats`
  e.g. `03-foo.md` → `scaffold/03-foo.bats`
```

**Problem:** Spec line 15 says `03-foo.md` → `scaffold/03.bats` (number only). Implementation uses the full filename slug.

**Reason skipped:** User explicitly corrected this: "ça doit porter le même nom que le nom de l'issue. Donc si l'issue, elle s'appelle 03-implement-routing.md, ça doit s'appeler 03-implement-routing.bats". User instruction overrides spec text.

---

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

## Issue 04 — Rewrite tdd skill

### Philosophy/Anti-Pattern sections lack Goal/Exit criterion (Standards)
```markdown
## Philosophy
**Two legitimate testing levels:** ...

## Anti-Pattern: Horizontal Slices
...
```
**Problem:** Reviewer flagged that these sections don't have `**Goal:**` / `**Exit criterion:**` lines per the skill-template.
**Reason skipped:** Template requires Goal/Exit only for steps inside `## Core Workflow`. Philosophy and Anti-Pattern are context sections, not steps — the requirement doesn't apply.

### "Correct approach" rationale removed (Standards/Spec)
**Problem:** The original text "Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it." was deleted.
**Reason skipped:** The rationale is now implicit in Step 2 Tracer Bullet. The deletion is justified by the skill-writer rule to cut words that don't add meaning.
