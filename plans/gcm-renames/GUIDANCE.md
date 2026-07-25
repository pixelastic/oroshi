## Guidance

- Test command: `yarn run test scripts/bin/git/commit/git-commit-message/__tests__/<file>`
- Lint command: `yarn run lint:fix scripts/bin/git/commit/git-commit-message/<file>`
- Source files: `scripts/bin/git/commit/git-commit-message/`
- Test files: `scripts/bin/git/commit/git-commit-message/__tests__/`
- Gilmore is mocked in tests with `vi.mock('gilmore', () => ({ default: vi.fn() }))`
- Prerequisite: Gilmore must be bumped to version with `stagedFilesWithStatus()`, `parseStatus` rename support, and `stagedFiles` with `-M`
- The `→` character in the rename fallback block is U+2192 (rightwards arrow)

## Discoveries
