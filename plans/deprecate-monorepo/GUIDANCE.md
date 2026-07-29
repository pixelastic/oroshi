## Guidance

- Test command: `bats <filepath>`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`
- New helper location: `tools/term/zsh/config/functions/autoload/npm/npm-name`
- Tests location: `tools/term/zsh/config/functions/autoload/npm/__tests__/npm-name.bats`
- Caller to update: `scripts/bin/ai/deprecate/deprecate-prepare` (lines 54-58)
- Prior art for tests: `yarn-package-is-private.bats` (filesystem fixtures), `yarn-is-monorepo.bats` (monorepo setup + mocking)
- Use `bats_tmp_dir`, `bats_disable_worktree_aware`, `bats_mock` patterns from prior art
- `npm-name` reads `workspaces` via `jq` directly — does not depend on `yarn-is-monorepo` or git
- Mock `yarn-package-is-private` and `yarn-package-name` in tests — they are immediate collaborators

## Discoveries
