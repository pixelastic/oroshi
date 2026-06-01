## TLDR

Add `scaffolding-test` and `permanent-test` as optional fields to the issue template, and update the ToIssues skill to populate and display them.

## What to build

Update `to-issues/references/issues-XX-slug.md` to include two optional fields in the issue template. Update `to-issues/SKILL.md` so that when drafting issues (step 2), the agent reasons about test type and fills in the appropriate fields; and when confirming with the user (step 3), the fields are visible in the proposed breakdown.

The two fields:
- `scaffolding-test:` — prose description of what the scaffolding test must verify (omit if not needed)
- `permanent-test:` — prose description of what the permanent test must verify (omit if not needed)

Both absent = `neither` (no test). One present = single type. Both present = mixed task.

The agent at ToIssues time uses the issue type as a heuristic: feature → `permanent-test`, refactoring → `scaffolding-test`, mixed → both. These are defaults that Ralph may override with implementation context.

## Acceptance criteria

- [ ] `issues-XX-slug.md` template includes both optional fields with inline comments explaining when to omit each
- [ ] `to-issues/SKILL.md` step 2 instructs the agent to reason about test type and populate the fields for each issue
- [ ] `to-issues/SKILL.md` step 3 shows `scaffolding-test` and `permanent-test` values in the confirmation list presented to the user
- [ ] `to-issues/SKILL.md` checklist includes a step verifying both fields were considered for each issue
