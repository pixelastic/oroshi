## TLDR

Create `tdd/scaffolding.md` as the source of truth for scaffolding vs permanent tests, and reference it in `tdd/SKILL.md`.

## What to build

Add a new reference doc `tdd/scaffolding.md` that defines the two test categories, the pivot question used to distinguish them, the path convention for scaffolding tests, lifecycle rules, and the `neither` and `both` patterns. Then update `tdd/SKILL.md` to load this doc during the Planning phase, before any tests are written.

The doc must cover:
- **Permanent tests**: test observable behavior through the public API; survive any internal rewrite
- **Scaffolding tests**: verify a structural transformation happened; live at `plans/<slug>/scaffold/issue-N.bats`; deleted by the human when archiving the plan
- **The pivot question**: "If I rewrote the internals from scratch while keeping the same public API, would this test still pass?" YES → permanent. NO → scaffolding.
- **`neither`**: binary installation, HITL issues, config-only changes — no test at all
- **`both`**: the permanent test mocks the underlying method and tests the higher layer's behavior; the scaffolding test verifies the underlying method was correctly implemented
- **lint-staged wiring**: scaffolding at most (verify the config file was written correctly); never trigger an actual pre-commit run

## Acceptance criteria

- [ ] `tdd/scaffolding.md` exists with all sections: pivot question, permanent definition, scaffolding definition, path convention, lifecycle, `neither` rule, `both` pattern, lint-staged rule
- [ ] `tdd/SKILL.md` Planning phase references `scaffolding.md` and instructs the agent to read it before writing any test
- [ ] `tdd/SKILL.md` checklist includes a step: "Declared test strategy (scaffolding / permanent / both / neither) before writing any test"
