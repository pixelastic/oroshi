## TLDR

Update Ralph's RED step to read `scaffolding-test` / `permanent-test` from the issue, declare test strategy explicitly, override if needed, and route tests to the correct location.

## What to build

Update `ralph/SKILL.md` Step 2 (RED) to integrate scaffolding awareness. Before writing any test, Ralph must:

1. Read `scaffolding-test` and `permanent-test` fields from the issue
2. Optionally override them based on implementation context (e.g. existing permanent tests already cover the behavior → no new permanent test needed; task declared scaffolding-only turns out to introduce new behavior → add permanent test)
3. Declare the test strategy explicitly — one visible statement of what goes in scaffolding, what goes in permanent — before writing any code
4. Route scaffolding tests to `plans/<slug>/scaffold/issue-N.bats` (create the `scaffold/` directory if needed)
5. Route permanent tests to `__tests__/` as usual

The scaffold path uses the issue id (`N`) matching the issue filename number (e.g. issue `03-foo.md` → `scaffold/03.bats`).

## Acceptance criteria

- [ ] `ralph/SKILL.md` Step 2 reads `scaffolding-test` and `permanent-test` from the issue before writing any test
- [ ] Step 2 includes an explicit declaration step: "Test strategy: scaffolding → [description or none], permanent → [description or none]"
- [ ] Step 2 allows Ralph to override the declared fields with a brief justification when implementation context warrants it
- [ ] Scaffolding tests are written to `plans/<slug>/scaffold/issue-N.bats`, not to `__tests__/`
- [ ] Permanent tests are written to `__tests__/` as before
- [ ] `ralph/SKILL.md` checklist includes: "Declared test strategy before writing any test"
- [ ] `ralph/SKILL.md` checklist includes: "Scaffolding tests written to plans/<slug>/scaffold/, not __tests__/"
