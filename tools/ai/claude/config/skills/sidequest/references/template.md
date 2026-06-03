# Sidequest Document Template

Sections marked **[VERBATIM]** must be copied exactly as written — do not paraphrase or reorder.
Sections marked **[DYNAMIC]** must be filled in from the conversation context.

---

```markdown
# Sidequest — <title> [DYNAMIC]

## Agent Instructions [VERBATIM]

1. Read this document
2. Summarize back to the user: the problem, the context, and the objective.
3. Research the codebase
4. Present your proposed solution (approach, files affected, trade-offs)
5. Invoke `/grill-me` to validate the approach before any implementation.

---

## Context [DYNAMIC]

- Summarize the current conversation so a fresh agent can pick up the work.
- What the problem or goal is
- Relevant filepaths (references only, not duplicate content)
- Suggested skills (if any)
```
