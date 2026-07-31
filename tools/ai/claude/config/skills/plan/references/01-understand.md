# Understand

Reach shared understanding of the problem, then map the codebase and identify modules.

1. Clarify intent — use `/grill-me` if context is insufficient
2. Explore codebase — domain glossary, relevant code
3. Sketch modules — confirm with user

---

## Clarify intent

**Goal:** Reach shared understanding of the problem and the intended solution.

**Exit criterion:** Problem is clear enough to explore code and sketch modules.

If the conversation already contains a clear problem statement (e.g. coming out
of a `/grill-me` session), skip to Explore codebase.

Otherwise, use `/grill-me` to clarify intent before proceeding.

---

## Explore codebase

**Goal:** Understand the current state of the codebase.

**Exit criterion:** Domain vocabulary and relevant code explored.

- Explore the repo to understand the current state of the code.
- Look for relevant `GLOSSARY.md` files and use their vocabulary throughout the plan.

---

## Sketch modules

**Goal:** Identify the deep modules to build or modify.

**Exit criterion:** User confirmed module list.

Sketch the major modules needed. Actively look for opportunities to extract
deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) encapsulates a lot of
functionality in a simple, testable interface which rarely changes.

Check with the user:
- Do these modules match their expectations?

## Checklist

- [ ] Problem and solution are clear (via `/grill-me` or prior context)
- [ ] Codebase explored — domain glossary and decisions identified
- [ ] Deep modules identified — each has a simple, testable interface
- [ ] User confirmed module list matches intent
