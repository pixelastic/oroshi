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
- `rtk.bats` setup copies `filters.toml` to `$BATS_TMP_DIR` and sets `XDG_CONFIG_HOME` so RTK uses the local copy. JS fixture files must NOT be placed under `$BATS_TMP_DIR` — vitest exclude `**/tmp/**` matches the entire path including absolute `/tmp/...` paths. Use a slug-named subdirectory under `$BATS_TEST_DIRNAME/.bats-fixtures/` instead; this keeps files inside the project tree under `__tests__/` so vitest can discover them.

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

### Issue 01 — fix rtk-can-rewrite
- ZSH uses POSIX ERE via glibc on Linux, which supports `\b` as a word boundary — use `\b` anchors in `=~` patterns directly (no PCRE module needed).
- Sequential `[[ "$cmd" =~ pattern ]] && return 0` lines are preferred over a `for` loop over a patterns array — same behavior, no avoidable nesting.

### Issue 02 — yarn/vitest filter
- Vitest `**/tmp/**` exclude applies to absolute paths — `/tmp/oroshi/...` is excluded even when passed explicitly. JS fixtures must live inside the project tree under a `__tests__/` subdirectory.
- Variables in bats `setup()` that need to persist to `@test` and `teardown()` must NOT use `local` — this overrides the usual zsh-writer "all function vars local" rule.
- `strip_ansi = true` strips ANSI for pattern matching but kept lines retain their original color codes in output (intentional — colors help LLM context).
