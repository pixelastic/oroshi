## Guidance

### Context

This PRD adds `yarn run test` (aberlaas/Vitest) to the RTK filtering pipeline that already handles `bats`. Two changes are needed: fix the detection function and add the TOML filter.

### Key files

- `tools/term/zsh/config/functions/autoload/ai/rtk/rtk-can-rewrite` — autoload function to fix
- `tools/term/zsh/config/functions/autoload/ai/rtk/__tests__/rtk-can-rewrite.bats` — tests to rewrite
- `tools/ai/rtk/config/filters.toml` — add `[filters.yarn]` entry
- `tools/ai/rtk/__tests__/rtk.bats` — add yarn test cases

### Testing commands

```zsh
bats tools/term/zsh/config/functions/autoload/ai/rtk/__tests__/rtk-can-rewrite.bats
bats tools/ai/rtk/__tests__/rtk.bats
bats-lint tools/term/zsh/config/functions/autoload/ai/rtk/__tests__/rtk-can-rewrite.bats
bats-lint tools/ai/rtk/__tests__/rtk.bats
zsh-lint tools/term/zsh/config/functions/autoload/ai/rtk/rtk-can-rewrite
```

### Architecture notes

- `rtk rewrite "<cmd>"` — detects built-in RTK rewrites only (git, gh, pnpm…). Exits 0 + prints rewritten command. Does NOT check TOML filters.
- `rtk-can-rewrite "<cmd>"` — detection helper used by the preToolUse-Bash hook. Exits 0 if RTK can handle the command (built-in or TOML filter), exits 1 otherwise. No stdout.
- `[filters.yarn]` in TOML — used by the RTK binary at execution time. `match_command` guards which yarn commands get filtered; non-matching commands (e.g. `yarn install`) pass through unchanged.
- `rtk.bats` setup copies `filters.toml` to `$BATS_TMP_DIR` and sets `XDG_CONFIG_HOME` so RTK uses the local copy. New yarn tests must create `.js` fixture files under `$BATS_TMP_DIR` inside a `__tests__/` subdirectory (vitest excludes `/tmp`).

### Vitest output format (from prototyping)

All-passing output (after ANSI strip) contains lines like:
- ` ✓ file.js (N tests) Nms` — strip
- ` Test Files  N passed (N)` — strip (all-passing pattern)
- `   Start at  HH:MM:SS` — strip

Failing output additionally contains:
- ` ❯ file.js (N tests | N failed)` — keep
- ` × failing test name` — keep
- `AssertionError: expected X to be Y` — keep
- ` Test Files  N failed | N passed (N)` — keep (mixed pattern, not stripped)

### Vitest include pattern

aberlaas/Vitest only picks up files matching `**/__tests__/**/*.js?(x)` and excludes `**/tmp/**`. Test fixture `.js` files must be placed inside a `__tests__/` subdirectory within `$BATS_TMP_DIR`.

## Discoveries

<!-- Agents append findings here after each issue -->
