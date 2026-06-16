## Guidance

### Context

This plan improves commit message quality by fixing root causes at each layer:
- ralph skill: COMMIT_HINT.md template and step structure
- prd skill: add COMMIT_HINT.md authoring at plan creation time
- git-commit-message script: deterministic plan-deletion strategy

### File locations

Skills live under `tools/ai/claude/config/skills/`. Edit files in the worktree only — never via the symlink in `~/.claude/skills/`.

- ralph skill: `tools/ai/claude/config/skills/ralph/`
- prd skill: `tools/ai/claude/config/skills/prd/`
- commit prompts: `scripts/bin/git/commit/git-commit-message/prompt-with-hint.md` and `prompt-without-hint.md`
- git-commit-message entry point: `scripts/bin/git/commit/git-commit-message/git-commit-message.js`

### Testing

- JS tests: `yarn run test <filepath>` (vitest via aberlaas)
- Issue 03 introduces the first vitest test file in this repo — place it in `__tests__/` next to the module under test
- No tests for skill or prompt file changes (config artifacts)

### Conventions

- `plan` is a project-local commit type (not in Conventional Commits spec); scope is the plan slug
- Plan sentinel files: `plans/<slug>/PRD.md` and `plans/<slug>/state.json` — both deleted = plan deletion
- ralph's COMMIT_HINT.md is ephemeral (deleted by post-commit hook); review-log.md, state.json, GUIDANCE.md are committed repo files
- The detection module for plan deletion must be a pure function (input: staged file list, output: string or null) to enable testing without a real git repo

### Prior art

- Existing strategy modules: `commitWithHint.js` and `commitWithoutHint.js` — follow the same module pattern for the new detection module
- Other skills with references subdirectories: `tdd/references/`, `js-writer/references/` — follow the same pattern for `ralph/references/`

## Discoveries

