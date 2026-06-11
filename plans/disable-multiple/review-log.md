## Issue 01 — Multi-rule disable

### Spec: bats tests use different rule codes than `noRunZsh,noInlineFunction`

```bats
@test "bats-lint disable=X,Y suppresses both violations on next line" {
  printf '# bats-lint disable=noTopLevelVar,preferZshAutoload\nCURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/fn"\n' >"$file"
```

**Problem:** Spec explicitly names `noRunZsh,noInlineFunction` as the disabled pair in the batslint behavioral tests. The implementation uses `noTopLevelVar,preferZshAutoload` instead.

**Reason skipped:** `noRunZsh` and `noInlineFunction` cannot co-fire on a single line. `noRunZsh` fires on lines matching `^run zsh` (command invocations); `noInlineFunction` fires on lines matching `^funcname()` (function definitions). These patterns are structurally exclusive — no line can simultaneously be a plain command call and a function definition. `noTopLevelVar,preferZshAutoload` both fire on `CURRENT="$OROSHI_ROOT/.../autoload/..."` and are the only co-fire pair in the bats rule set.
