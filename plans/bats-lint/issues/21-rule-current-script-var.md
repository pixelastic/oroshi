## TLDR

Add a new `currentScriptVar` rule to `bats-lint`: flag any uppercase variable
assigned `"$BATS_TEST_DIRNAME/../{basename}"` that is not named `CURRENT`.

## Context

By convention the variable holding the script under test is named `CURRENT`.
Several test files use ad-hoc names (`PRD_END_SCRIPT`, `REVIEW_SCRIPT`,
`PLAN_DIRECTORY`, `RALPH_START`, `PLAN_PROGRESS`, `POST_COMMIT`) instead.
Enforcing the `CURRENT` name makes tests immediately readable — the reader
always knows which variable is the SUT without scanning for context.

**Detection signal:** the value `"$BATS_TEST_DIRNAME/../{basename}"` (where
`{basename}` is the test filename without `.bats`) is unambiguous: it is always
the path to the script under test. Exact basename match (no trailing extension)
excludes legitimate non-SUT paths such as
`RULE_PATH="${BATS_TEST_DIRNAME}/../rule-prefer-zsh-autoload.zsh"`.

## What to build

### 1. Rule file

Create `scripts/bin/term/bats/bats-lint/__rules/rule-current-script-var.zsh`:

```zsh
# Custom Rule: batsLintRule_currentScriptVar
# Detects when the script under test is not assigned to CURRENT.
# A variable assigned "$BATS_TEST_DIRNAME/../{basename}" (where basename is
# the test filename without .bats) must be named CURRENT.
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-current-script-var.zsh
#   batsLintRule_currentScriptVar <file.bats>
batsLintRule_currentScriptVar() {
  local code='currentScriptVar'

  local file="$1"
  local basename="${${1:t}%.bats}"
  local content="$(<"$file")"
  local lineno=0
  local line
  # Both brace forms: $BATS_TEST_DIRNAME and ${BATS_TEST_DIRNAME}
  local pat1='^[[:space:]]*([A-Z_][A-Z0-9_]*)="\$BATS_TEST_DIRNAME/\.\./'"${basename}"'"$'
  local pat2='^[[:space:]]*([A-Z_][A-Z0-9_]*)="\$\{BATS_TEST_DIRNAME\}/\.\./'"${basename}"'"$'

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ ! "$line" =~ $pat1 && ! "$line" =~ $pat2 ]] && continue
    [[ "$line" =~ '^[[:space:]]*CURRENT=' ]] && continue
    [[ "$line" =~ '^[[:space:]]*([A-Z_][A-Z0-9_]*)=' ]]
    local varname="${match[1]}"
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" \
      "prefer using CURRENT, not \`${varname}\` for script under test"
  done
}
```

### 2. Register the rule

In `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`, add:

```zsh
source "${_batsLintRulesDir}/rule-current-script-var.zsh"
```

And add `batsLintRule_currentScriptVar` to the `lint-custom-run` call.

### 3. Test file

Create `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-current-script-var.bats`.

The fixture filename is `"test.bats"` so the rule derives `basename=test`.

```bash
bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-current-script-var.zsh" \
    "batsLintRule_currentScriptVar" "test.bats" "$@"
}
```

**Cases to cover:**

- Non-CURRENT name (no braces) → violation: `PRD_END_SCRIPT="$BATS_TEST_DIRNAME/../test"`
- Non-CURRENT name (braced form) → violation: `PLAN_DIR="${BATS_TEST_DIRNAME}/../test"`
- `CURRENT=` (no braces) → no violation: `CURRENT="$BATS_TEST_DIRNAME/../test"`
- `CURRENT=` (braced form) → no violation: `CURRENT="${BATS_TEST_DIRNAME}/../test"`
- Value has trailing extension → no violation: `RULE_PATH="${BATS_TEST_DIRNAME}/../test.zsh"`
- Value does not match basename → no violation: `SCRIPT="$BATS_TEST_DIRNAME/../other"`
- `local` prefix → no violation: `local script="$BATS_TEST_DIRNAME/../test"`
- Inside `run_this_rule` string arg → no violation: `  run_this_rule 'SCRIPT="$BATS_TEST_DIRNAME/../test"'`
- Correct line number reported
- Indented violation (inside setup) still detected

### 4. Fix violations

Rename the SUT variable to `CURRENT` (assignment + all uses) in:

| File | Current name |
|---|---|
| `scripts/bin/ai/prd/__tests__/prd-end.bats` | `PRD_END_SCRIPT` |
| `scripts/bin/ai/review/__tests__/review.bats` | `REVIEW_SCRIPT` |
| `scripts/bin/ai/ralph/__tests__/plan-directory.bats` | `PLAN_DIRECTORY` |
| `scripts/bin/ai/ralph/__tests__/ralph-start.bats` | `RALPH_START` |
| `scripts/bin/ai/ralph/__tests__/plan-progress.bats` | `PLAN_PROGRESS` |
| `scripts/yarn/hooks/__tests__/post-commit.bats` | `POST_COMMIT` |

## Acceptance criteria

- [ ] `batsLintRule_currentScriptVar` flags a non-CURRENT name → `currentScriptVar` error
- [ ] Both brace forms (`$BATS_TEST_DIRNAME` and `${BATS_TEST_DIRNAME}`) trigger
- [ ] `CURRENT=` at any indent → no violation
- [ ] Value with trailing extension (`.zsh`) → no violation
- [ ] Value not matching basename → no violation
- [ ] `local var=` lines → no violation (anchor excludes `local` prefix)
- [ ] String literals inside helper calls → no violation (anchor excludes quoted content)
- [ ] Rule registered in `bats-lint-custom.zsh` and included in `lint-custom-run`
- [ ] Rule test file passes `bats`
- [ ] Rule file passes `bats-lint` and `zsh-lint`
- [ ] All 6 violation files fixed: `bats-lint` exits 0, `bats` passes
