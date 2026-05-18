## Execution order

0001-eslint-shebang → no blockers
0008-claude-print-no-session-persistence → no blockers
0002-format-message → needs 0001
0003-script-core → needs 0002
0004-error-handling → needs 0003
0005-sound → needs 0003
0007-delete-commit-writer-skill → needs 0003
0006-neovim-wiring-cleanup → needs 0004 + 0005

## Guidance

All JS follows the js-writer skill style: named imports only (`import { x } from 'firost'`),
no god-object usage. `golgoth` and `firost` imports come before Node built-ins
(`import/order` enforced by ESLint).

The new script lives at `scripts/bin/git/commit/git-commit-message` with
`#!/usr/bin/env node`. The repo `package.json` has `"type": "module"` — use
ESM imports throughout.

Run `yarn lint` after every change. The ESLint config uses `aberlaas` which
enforces `eslint-plugin-n`, `eslint-plugin-import`, and prettier.

`formatMessage` must be a named export so vitest can import it. The vitest
setup is bootstrapped in issue-0002 — check if `vitest.config.js` already
exists before creating one.

For the Anthropic API call: use native `fetch()` (Node 22), no `@anthropic-ai/sdk`.
Model: `claude-sonnet-4-5`. Key from `process.env.ANTHROPIC_API_KEY`.

`rtk` is in `$PATH` — use `rtk git status` and `rtk git diff` to reduce
token noise before sending to the API.

Sound: `child_process.spawn('audio-play-oroshi', ['git-commit-message.mp3'],
{ detached: true, stdio: 'ignore' }).unref()` — never await.

---
## Log (append below when an issue is completed)

## Session 2026-05-17 — 0001: eslint-shebang
- Completed: Added `n/hashbang: off` override for `scripts/bin/**` in eslint.config.js
- Tests added: scripts/bin/__tests__/eslint-shebang.bats
- Discovered: Parser itself handles shebangs fine once the `\` in printf was removed (user fix)
- Fixed: Hardcoded PROJECT_ROOT in bats test → replaced with `$BATS_TEST_DIRNAME/../../..`
- Skipped feedback: `js-lint` vs `yarn lint` in test — bats tests call CLI tools directly, which is standard in this repo
- Next: 0002-format-message (vitest setup + formatMessage implementation)
