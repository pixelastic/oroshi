## TLDR

Create the `python-writer` skill: SKILL.md with four-step TDD workflow, plus two reference files.

## What to build

Create `tools/ai/claude/config/skills/python-writer/` with:

### `SKILL.md`

Four-step workflow mirroring `zsh-writer`:

- **Step 1 — Place the file**: conventions for where Python files live in the repo
- **Step 2 — TDD: Write a failing test**: write `test_<module>.py` in a `__tests__/` sibling directory; run `python-test <filepath>` to confirm it fails; link to `references/testing.md`
- **Step 3 — Write the code**: follow patterns in `references/style.md`; run `python-test <filepath>` to confirm it passes
- **Step 4 — Lint**: run `python-lint --fix <file>` on any modified `.py` files; fix every remaining violation

Include a checklist and a Common Rationalizations table (at minimum: return early).

### `references/testing.md`

Generic pytest conventions:
- Test file naming: `test_<module>.py` in `__tests__/`
- How to write a pytest test function (`def test_<behavior>():` + `assert`)
- `conftest.py` purpose: shared fixtures and import stubs, placed at the project root
- How to stub unavailable imports via `sys.modules` (the pattern itself, not kitty-specific)
- `@pytest.mark.parametrize` for testing the same behavior with multiple inputs
- How to run: `python-test <filepath>`

### `references/style.md`

Single rule: **return early**. No avoidable nesting. With a before/after Python example.

## Acceptance criteria

- [ ] `tools/ai/claude/config/skills/python-writer/SKILL.md` exists with all four steps
- [ ] Step 2 references `python-test` as the test runner command
- [ ] Step 4 references `python-lint --fix` as the lint command
- [ ] `references/testing.md` covers: test naming, conftest.py, sys.modules stub pattern, parametrize, run command
- [ ] `references/style.md` covers return early with a Python example
- [ ] Skill description in frontmatter triggers on "writing or modifying Python code"
- [ ] Checklist present in SKILL.md
