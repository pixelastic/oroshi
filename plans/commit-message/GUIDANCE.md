## Guidance

### Project layout

- Main script and its modules live together in the same directory under `scripts/bin/git/commit/git-commit-message/`
- Tests live in `__tests__/` inside that directory
- The Ralph skill is at `~/.claude/skills/ralph/SKILL.md`
- Post-commit hooks location: check where existing git hooks are wired in the repo before adding a new one

### Commands

- **Run JS tests:** `yarn run test scripts/bin/git/commit/git-commit-message/__tests__/`
- **Lint JS:** `yarn run lint:fix <filepath>`
- **Run bats tests:** `bats <filepath>`

### Conventions

- One exported function per JS file; file name matches function name
- Internal/private functions in the main script use no special prefix — they are just unexported
- Use `firost` for all file I/O in JS (read, exists, absolute, dirname…)
- Use `golgoth` for utility functions (`_`)
- Subprocess calls use the existing `Gilmore` pattern or `child_process` — check prior art before choosing
- Bats stubs use `bats_mock`; `.zshenv` rebuilds PATH so use `bats_run_script` to source scripts directly
- `plan-directory` is a zsh script; call it as a subprocess

### Prior art

- Existing `__tests__/git-commit-message.js` shows how to mock `fetch` and `Gilmore`
- Other bats tests in `scripts/bin/ai/ralph/__tests__/` show `bats_mock` usage for `plan-directory`

## Discoveries

