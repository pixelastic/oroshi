## Guidance

- Test command for zsh-fix: `bats scripts/bin/zsh/zsh-fix/__tests__/zsh-fix.bats`
- Test command for zsh-lint: `bats scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`
- Lint command: `zsh-lint <filepath>`
- Bats lint: `bats-lint <filepath>`
- Use `/zsh-writer` skill for ZSH implementation
- Use `/tdd` skill for test-driven development
- Tests use `bats_run_zsh` to run commands, `bats_mock` for mocking collaborators
- All test variables go in `setup()`, not at file top level
- Fixture `fixture-unformatted.txt` uses `.txt` extension intentionally — prevents auto-formatting by editors and lint-staged
- beautysh modifies files in place (no stdout mode) — tmpdir pattern needed for stdout output
- beautysh flags: `--indent-size 2`
- shfmt remains installed globally for bash/sh — only removed from zsh-fix

## Discoveries

### Issue 01 — Rewrite zsh-fix with beautysh
- Both fixture files use `.txt` extension — `.zsh` triggers zshlint on fixture content (e.g. `case "$1"` → noManualArgParsing)
- In-place mode runs beautysh directly on the file (no tmpdir round-trip), stdout modes use tmpdir copy
- Bats `setup()` vars must NOT use `local` — they need to be visible in `@test` blocks
