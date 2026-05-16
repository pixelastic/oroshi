## PRD

docs/git-commit-message/PRD.md

## What to build

Extend the ESLint config with an override that disables the `n/hashbang` rule
for all files under `scripts/bin/**`. This is a prerequisite for adding a
Node.js script with a `#!/usr/bin/env node` shebang in that directory.

The pattern mirrors the existing `aberlaas-lint` override that already disables
`no-process-exit` for `scripts/**`.

## Acceptance criteria

- [ ] `eslint.config.js` has an override for `scripts/bin/**` setting `n/hashbang: off`
- [ ] `yarn lint` passes on a file containing `#!/usr/bin/env node` in `scripts/bin/`

## Blocked by

None - can start immediately
