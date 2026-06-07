## Guidance

### Goal

Bring all ~120 BATS test files to zero violations under `bats-lint` (shellcheck + custom rules). Each issue is one domain. Process domains sequentially — the ruleset evolves as you go, and issue 17 does the final global cleanup.

### Process per domain

1. Run `bats-lint <file>` on each file in the domain
2. For each violation, present it to the developer and decide: **fix** / **exception** / **new rule**
3. If a new rule is needed: implement it (rule file + test file + fixtures) in the same session
4. Confirm: `bats-lint` exits 0 on all domain files + `bats` passes on all domain files
5. Mark the issue done in `state.json` and add a Discoveries entry below

### Commands

```zsh
# Lint a file
bats-lint <filepath>

# Run tests
bats <filepath>

# Lint all files in a directory
bats-lint <dir>/**/*.bats(N)
```

### File locations

- bats-lint tool: `scripts/bin/term/bats/bats-lint/`
- bats-lint rules: `scripts/bin/term/bats/bats-lint/__rules/`
- bats-lint rule tests: `scripts/bin/term/bats/bats-lint/__rules/__tests__/`
- BATS helper: `tools/term/bats/config/helper`
- BATS rules-helper: `tools/term/bats/config/rules-helper`

### bats-lint rule interface

Each rule outputs: `file▮code▮severity▮line▮message` (separator = U+25AE ▮)
Inline disable: `# bats-lint-disable <RuleCode>` on the offending line.
Prior art: `rule-no-run-zsh.zsh`, `rule-no-inline-function.zsh`

### Done criteria per issue

- `bats-lint` exits 0 on every file in the domain
- `bats` passes on every file in the domain
- Developer review sign-off

### Key conventions

- All test variables declared inside `setup()`, not at file top level
- Use `bats_run_zsh` (never `run zsh`)
- Use `bats_mock` for stubs (no env-var mocks in prod code)
- `bats-lint` must be run explicitly from the worktree (git-file-lint may miss untracked files)

### Prior art for rule tests

- `rule-no-run-zsh.bats` — minimal fixture, tests violation + clean case
- `rule-no-inline-function.bats` — tests length and multi-instruction variants

## Discoveries

<!-- Agents: append findings after each completed issue using the format below -->
<!-- ### Issue XX — short title -->
<!-- - Non-trivial finding -->

### Issue 05 — lint pass theming + prompt

- SC2155 (`local var="$(cmd)"`) in BATS files: **do not split** — project convention (`feedback_zsh_local_assignment.md`) forbids `local var; var=...`. Added SC2155 to global `excludedRules` in `bats-lint-shellcheck.zsh` instead.
- `noTopLevelVar` in BATS: move constants assigned at file top level into `setup()` — no `local` needed, they'll be accessible in `@test` blocks.
- **bats-lint inside `bats` tests = worktree version** (helper pins `OROSHI_ROOT` → worktree `scripts/bin` lands first in PATH). Terminal `bats-lint` = system version. To lint from terminal with worktree rules: call `scripts/bin/term/bats/bats-lint/bats-lint` directly.

### Issue 07 — lint pass misc utils

- SC2088 fires on `'~/...'` in single-quoted POSIX `[ ]` assertions — shellcheck flags tilde in any quoted context. Inline fix (`# shellcheck disable=SC2088`) must go on the **line before** the assertion; putting it at end-of-line causes SC1072 ("Unexpected shellcheck annotation") because shellcheck can't parse the bats `@test` block past the comment.

### Issue 10 — lint pass tools/ai

- SC2030/SC2031 (`export VAR=...` inside `@test` blocks): shellcheck flags these as local-to-subshell modifications. False positives in BATS context — added both to global `excludedRules` in `bats-lint-shellcheck.zsh`.

### Issue 01 — lint pass bats-lint (meta domain)

- 3 `noInlineFunction` violations in `bats-lint.bats` (lines 29, 31, 42): inline JSON-producing stubs exceeded 90 chars. Decision: **fix** (split to multi-line). Short stubs in the same file (≤ 90 chars, single instruction) are compliant and stay inline — the rule deliberately allows those.
- `bats-lint` exits 0 on missing files (outputs `[]`), which silently passes lint tests written with bad paths. Always guard with `[[ -f "$file" ]] || fail` before calling `bats-lint` in scaffold tests.
