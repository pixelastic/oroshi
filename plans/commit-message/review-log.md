## Issue 03 — Post-commit hook

### set -e omitted

```zsh
#!/usr/bin/env zsh
# ...
planDir="$(plan-directory 2>/dev/null)"
```

**Problem:** Standards reviewer flagged that shebang scripts require `set -e` per zsh-writer header conventions.

**Reason skipped:** The spec requires the hook to "never fail loudly — any error exits 0". With `set -e`, any failing command (e.g., `plan-directory` returns 1) would propagate a non-zero exit before the guard can fire. Omitting `set -e` and using explicit `exit 0` at the end satisfies the spec constraint.

### COMMIT_HINT.md vs COMMIT_HINT naming

```zsh
hintPath="${planDir%/}/COMMIT_HINT.md"
```

**Problem:** Spec issue text refers to `COMMIT_HINT` (no extension) throughout. Implementation targets `COMMIT_HINT.md`.

**Reason skipped:** The full codebase consistently uses `COMMIT_HINT.md`: `.gitignore` has `plans/*/COMMIT_HINT.md`, `SKILL.md` says `COMMIT_HINT.md`, `getCommitHint.js` reads `COMMIT_HINT.md`. The issue spec was imprecise; `COMMIT_HINT.md` is correct.

### Hook wiring not in diff

**Problem:** Spec acceptance criterion "Hook is wired into the repo (correct location so git invokes it)" — reviewer flagged no wiring change in diff.

**Reason skipped:** `core.hooksPath=scripts/yarn/hooks` is already set in the repo's git config. The pre-commit hook lives in the same directory and is already invoked by git. No additional wiring is needed; placing `post-commit` in `scripts/yarn/hooks/` is sufficient.

## Issue 02 — Commit hint wiring

### getCommitHint in separate module vs. main script

```js
// getCommitHint.js
export async function getCommitHint() { ... }
```

**Problem:** Spec acceptance criterion says "`getCommitHint()` exists in the main script". Reviewer flagged the function lives in a separate module instead.

**Reason skipped:** The main script (`git-commit-message.js`) runs top-level code at import time. If `getCommitHint` were internal to the main script, importing the main script in tests would trigger API calls, env var checks, and git operations — requiring mocking of every dependency before dynamic import. Extracting to a separate module is the only clean testable design.

### buildSystemPrompt in separate module vs. inline in main script

```js
// buildSystemPrompt.js
export function buildSystemPrompt(template, hint) { ... }
```

**Problem:** Spec says the `{{COMMIT_HINT}}` replacement logic should live inline in the main script wiring. Reviewer flagged a separate module wasn't specified.

**Reason skipped:** Same root cause. A pure function module is directly unit-testable and covers the spec's "main script" behavioral tests (prompt with/without hint instruction) exactly. Inline logic would require the same complex `vi.doMock` + dynamic import pattern to test.
