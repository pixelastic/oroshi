## Issue 01 — commandTooLong rule

### Standards: Missing header/usage block, setopt, setup/teardown, file-scope helper

```zsh
# Custom Rule: zshLintRule_commandTooLong
# Flags command invocations exceeding 100 characters
zshLintRule_commandTooLong() { ... }
```

**Problem:** Reviewer flagged missing `# Usage:` block, `setopt local_options err_return`, `setup()`/`teardown()` in tests, and `run_this_rule` at file scope.
**Reason skipped:** Rule files are sourced helpers, not autoloaded functions or standalone scripts. Prior art (`rule-single-equals-in-test.zsh` / `.bats`) has none of these. Applying these conventions would diverge from the established rule file pattern.

### Standards: `(( ++lineno ))` arithmetic

```zsh
(( ++lineno ))
```

**Problem:** Reviewer raised `noArithFlagTest` concern.
**Reason skipped:** `noArithFlagTest` targets `(( isFlag ))` boolean tests, not counter increments. Same pattern used in prior art; `zsh-lint` passes clean.

### Spec: Exactly-100-char clean line

**Problem:** Reviewer couldn't confirm the boundary line was exactly 100 chars.
**Reason skipped:** Verified with `wc -c`: `mycommand --opt1 val1 --opt2 val2 --opt3 val3 --opt4 val4 --opt5 val5 --opt6 val6 --opt7 val7-xxxxxx` = 100 chars exactly. Spec satisfied.
