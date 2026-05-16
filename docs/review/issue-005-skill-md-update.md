## PRD

[PRD — review-diff + review skill overhaul](./PRD.md)

## What to build

Update step 1 of `config/ai/claude/claudecode/skills/review/SKILL.md` to add two entry points:

1. **Filepath path**: if the argument matches the `review-diff-<uuid>.md` pattern, read the file directly with the Read tool. Do not call `review-diff`.
2. **Natural language path**: interpret the user's intent and translate to `review-diff` args, then call the script and use its stdout as diff context. Examples:
   - "review this branch" → `review-diff <current-branch>`
   - "review since main" → `review-diff main`
   - "review commit abc123" → `review-diff abc123`
   - "review main..feature" → `review-diff main feature`

All other steps (spec identification, standards sources, sub-agents) are unchanged.

This is a HITL issue — Tim must review and approve the SKILL.md wording before it is merged.

## Acceptance criteria

- [ ] SKILL.md step 1 describes the filepath detection path
- [ ] SKILL.md step 1 describes the natural language → `review-diff` translation path with concrete examples
- [ ] All other steps are unchanged
- [ ] Tim has reviewed and approved the wording

## Blocked by

- issue-001, issue-002, issue-003, issue-004 (review-diff interface must be finalised before documenting it)
