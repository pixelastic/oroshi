## TLDR

Add a new `preferBatchMock` rule to `bats-lint`: flag every `bats_mock` call
beyond the first one inside a single `@test` block.

## Context

`bats_mock` accepts multiple function names in one call. When a test defines
several mocks, calling `bats_mock` once per function is redundant and noisy.
The idiomatic form is a single call:

```bash
# bad
fn1() { ... }
bats_mock fn1
fn2() { ... }
bats_mock fn2

# good
fn1() { ... }
fn2() { ... }
bats_mock fn1 fn2
```

## What to build

### 1. Rule file

Create `scripts/bin/term/bats/bats-lint/__rules/rule-prefer-batch-mock.zsh`:

```zsh
# Custom Rule: batsLintRule_preferBatchMock
# Detects multiple bats_mock calls in the same @test block
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-prefer-batch-mock.zsh
#   batsLintRule_preferBatchMock <file.bats>
batsLintRule_preferBatchMock() {
  local code='preferBatchMock'
  local msg='Merge all bats_mock calls into one: bats_mock fn1 fn2 ...'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local inTest=0
  local mockCount=0

  for line in "${(@f)content}"; do
    (( ++lineno ))

    if [[ "$line" =~ '^@test' ]]; then
      inTest=1
      mockCount=0
      continue
    fi

    if [[ $inTest == "1" && "$line" =~ '^}' ]]; then
      inTest=0
      mockCount=0
      continue
    fi

    [[ $inTest != "1" ]] && continue
    [[ ! "$line" =~ '^[[:space:]]+bats_mock' ]] && continue

    (( ++mockCount ))
    [[ $mockCount -le 1 ]] && continue

    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
```

### 2. Register the rule

In `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`, add:

```zsh
source "${_batsLintRulesDir}/rule-prefer-batch-mock.zsh"
```

And add `batsLintRule_preferBatchMock` to the `lint-custom-run` call.

### 3. Test file

Create `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-prefer-batch-mock.bats`:

```bash
#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-prefer-batch-mock.zsh" \
    "batsLintRule_preferBatchMock" "test.bats" "$@"
}
```

**Cases to cover:**

- Single `bats_mock` in a `@test` → clean
- Two `bats_mock` in the same `@test` → violation on 2nd call
- Three `bats_mock` in the same `@test` → violations on 2nd and 3rd calls
- Two `bats_mock` each in separate `@test` blocks → clean
- `bats_mock` outside any `@test` block → clean
- `bats_mock fn1 fn2` (already grouped) → clean

## Acceptance criteria

- [ ] Two `bats_mock` calls in one `@test` → `preferBatchMock` error on 2nd line
- [ ] Three calls → errors on 2nd and 3rd lines
- [ ] One call per `@test` → no violation
- [ ] Rule registered in `bats-lint-custom.zsh` and included in `lint-custom-run`
- [ ] Rule test file passes `bats`
- [ ] Rule file passes `bats-lint` and `zsh-lint`
