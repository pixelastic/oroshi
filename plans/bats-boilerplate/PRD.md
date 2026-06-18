## Problem Statement

157 `.bats` test files each manually define the same one-line teardown:

```
teardown() { bats_cleanup; }
```

This appears in 95% of files that have any teardown at all (~120 files). It is pure boilerplate — it carries no information, adds noise to every test file, and creates a footgun: new test files that forget to include it silently leak temp directories.

## Solution

Define `teardown() { bats_cleanup; }` as the default teardown in the shared BATS helper, so test files get it for free. Files that need custom teardown logic override it entirely (Model A) and take responsibility for calling `bats_cleanup` themselves. A lint rule enforces that the now-redundant boilerplate cannot be re-introduced.

Default `setup()` is intentionally NOT added — keeping setup explicit preserves the signal that `$BATS_TMP_DIR` comes from a deliberate `bats_tmp_dir` call.

## User Stories

1. As a test author, I want teardown to be automatic, so that I don't need to remember to add a cleanup block to every new test file.
2. As a test author, I want to override the default teardown when I need custom cleanup, so that complex teardown scenarios remain possible.
3. As a test author writing a custom teardown, I want to understand my responsibility to call `bats_cleanup` myself, so that temp directories are always cleaned up.
4. As a test author, I want setup to remain explicit, so that the origin of `$BATS_TMP_DIR` is always visible in the file.
5. As a test author, I want `bats_cleanup` to be safe when called with no temp directory set, so that stateless test files (no setup) don't fail in teardown.
6. As a code reviewer, I want a lint rule that flags boilerplate teardowns, so that the pattern cannot be re-introduced after migration.
7. As an agent writing a new `.bats` file, I want the lint rule to immediately flag any accidental `teardown() { bats_cleanup; }` I write, so that I self-correct without human review.

## Implementation Decisions

### Commit 1 — Helper changes

- **Harden `bats_cleanup`:** Add an early-return guard when `$BATS_TMP_DIR` is empty or unset. Without this, a default teardown calling `bats_cleanup` on files with no setup would invoke `rm -rf ""`, which fails in bash and causes BATS to mark those tests as failed.
- **Add default `teardown()`:** Define `teardown() { bats_cleanup; }` in the helper. BATS resolves setup/teardown by name at call time — the last definition in bash scope wins. Since the helper is loaded via `bats_load_library` before the test file's own definitions, a test file's `teardown()` naturally overrides the helper's default.
- **Override model (Model A):** No hook mechanism (`teardown_extra`) is introduced. Custom teardowns replace the default entirely. There is currently only one file with a non-trivial teardown; it already calls `bats_cleanup` itself.
- **No default `setup()`:** The ~30 stateless test files (no temp dir needed) would create and delete useless directories on every test. Keeping setup explicit also preserves the readable signal of where `$BATS_TMP_DIR` comes from.

### Commit 2 — Lint rule `noBoilerplateTeardown`

- Detect `teardown()` whose body consists solely of a `bats_cleanup` call — both one-liner (`teardown() { bats_cleanup; }`) and multiline forms.
- Do NOT flag teardowns that call `bats_cleanup` alongside other statements.
- Register the rule in the bats-lint custom rules loader.
- Follows the existing rule API: function receives a file path, outputs violations as delimited text (`file▮code▮level▮line▮message`).

### Commit 3 — Migration

- Run `bats-lint` with the new rule across all 157 `.bats` files to identify the ~120 targets.
- Strip the boilerplate `teardown()` blocks from those files.
- The one file with a non-trivial teardown (`rtk.bats`) requires no change.

## Testing Decisions

Good tests exercise external behavior through the module's public interface, not implementation details.

### Module 1 — Helper (`bats_cleanup` guard + default teardown)

- **Tested:** Yes, extend the existing `helper.bats` test file.
- **What to test:**
  - `bats_cleanup` returns 0 and does nothing when `$BATS_TMP_DIR` is unset.
  - `bats_cleanup` removes the directory when `$BATS_TMP_DIR` is set.
  - A test file that loads the helper but defines no `teardown()` gets the default behavior (temp dir removed after test).
- **Prior art:** `tools/term/bats/config/__tests__/helper.bats`

### Module 2 — Lint rule `noBoilerplateTeardown`

- **Tested:** Yes, new dedicated `.bats` test file alongside the rule.
- **What to test:**
  - One-liner boilerplate teardown triggers a violation.
  - Multiline boilerplate teardown triggers a violation.
  - Teardown with `bats_cleanup` + additional statements does NOT trigger.
  - File with no teardown does NOT trigger.
  - `# bats-lint disable=noBoilerplateTeardown` suppresses the violation.
- **Prior art:** `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-run-zsh.bats`

### Module 3 — Migration

- **Tested:** No. One-off transformation; correctness is verified by running the full test suite after migration.

## Out of Scope

- Default `setup()` — explicitly decided against.
- Hook model (`setup_extra` / `teardown_extra`) — Model A (override) is sufficient given only one custom teardown exists.
- Migrating `setup() { bats_tmp_dir; }` boilerplate — lower ROI and would require a separate lint rule and migration.
- Any changes to `rules-helper` or the lint rule test infrastructure.

## Further Notes

The lint rule doubles as the migration tool: its output after commit 2 is the exact list of files to modify in commit 3. No separate file discovery step needed.
