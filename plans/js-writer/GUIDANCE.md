## Guidance

This plan spans two repositories.

### Issue 01 — aberlaas repo
- Repo: `/home/tim/local/www/projects/aberlaas`
- Rule file: `modules/lint/configs/eslint/rules/no-test-suffix.js`
- Config file to update: `modules/lint/configs/eslint/vitest.js`
- Tests: `modules/lint/lib/__tests__/vitest.js` (create if absent — follow the pattern in `modules/lint/lib/__tests__/js.js`)
- Test command: `yarn run test modules/lint/lib/__tests__/vitest.js`
- Lint command: `yarn run lint:fix`
- Prior art for integration tests: `modules/lint/lib/__tests__/js.js` — writes real files, calls `run()`/`fix()`, uses `vi.spyOn(helper, 'hostPackageRoot')` to redirect to a temp dir inside the repo (ESLint constraint: files must be inside the repo base directory)

### Issue 02 — oroshi repo
- Repo worktree: `/home/tim/local/www/worktrees/oroshi--js-writer`
- Skill files: `tools/ai/claude/config/skills/js-writer/SKILL.md` and `tools/ai/claude/config/skills/js-writer/references/testing.md`
- No tests — skill documentation is the artifact
- Lint command: `yarn run lint:fix` (if applicable)

### Conventions
- Test files in `__tests__/` use the plain module name — no `.test.` suffix
- One exported function per file; barrel files are named `index.js`
- `main.js` is reserved for the single top-level package entry point only
- ESLint rule severity: `error` (not `warn`); no auto-fix

## Discoveries
