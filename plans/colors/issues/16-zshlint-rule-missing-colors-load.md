## TLDR

Implement a custom zshlint rule (`missingColorsLoad`) that flags any ZSH file that accesses `$COLORS[...]` without calling `colors-load-definitions`.

## Background

Design decisions reached via grill-me (issue 11):

| Decision | Outcome |
|---|---|
| Check scope | All files zshlint processes — no filtering by extension or shebang. Same as every other zsh-lint rule. |
| Trigger patterns | `COLORS[` (subscript access, e.g. `$COLORS[red-1]`, `${COLORS[text]}`) and `${(k)COLORS}` (key enumeration). NOT `${#COLORS}` — too niche. |
| Detection strategy | Check for `colors-load-definitions` anywhere in the file (not positional). Report at the **first trigger line**, not line 1, so the existing `# zsh-lint disable=missingColorsLoad` mechanism works. |
| Exceptions | None hardcoded — use `# zsh-lint disable=missingColorsLoad` on the line above the first trigger. |
| Error message | "add 'colors-load-definitions' at top of file (after argument parsing if any)" |

## Implementation

### 1. New rule file

Create `scripts/bin/zsh/zsh-lint/__rules/rule-missing-colors-load.zsh`:

```zsh
# Custom Rule: zshLintRule_missingColorsLoad
# Detects functions/scripts that access $COLORS[] without calling colors-load-definitions
zshLintRule_missingColorsLoad() {
  local code='missingColorsLoad'
  local msg="add 'colors-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if colors-load-definitions is already present
  [[ "$content" =~ 'colors-load-definitions' ]] && return 0

  # Find first trigger line (COLORS[ subscript or ${(k)COLORS} enumeration)
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( lineNum++ ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ 'COLORS\[' || "$line" =~ '\$\{(\([^)]*\))?COLORS\}?' ]]; then
      firstTriggerLine=$lineNum
      break
    fi
  done

  [[ $firstTriggerLine -eq 0 ]] && return 0

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$firstTriggerLine" "$_SEP" "$msg"
}
```

### 2. Register in zsh-lint-custom.zsh

Add to `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh`:
- `source "${_zshLintRulesDir}/rule-missing-colors-load.zsh"` in the source block
- `zshLintRule_missingColorsLoad` in the `lint-custom-run` call

### 3. Fix existing violators

These files use `COLORS[` without `colors-load-definitions` and must be fixed:

| File | Fix |
|---|---|
| `tools/term/zsh/config/functions/autoload/git/branch/git-branch-color` | Add `colors-load-definitions` call |
| `tools/term/zsh/config/functions/autoload/misc/colorize` | Add `colors-load-definitions` call |
| `scripts/bin/colors` | Replace `source "$OROSHI_ROOT/.../dist/colors.zsh"` with `colors-load-definitions` |

### 4. Disable false positives

These files have `COLORS[` in non-ZSH contexts (jq strings) and need a disable comment:

| File | Location | Reason |
|---|---|---|
| `tools/term/zsh/config/theming/colors-build` | Above the first jq heredoc line containing `COLORS[` | `COLORS[` appears inside a jq string that generates the dist file — not a ZSH access |

## Behavioral Tests

Tests live next to the rule file: `scripts/bin/zsh/zsh-lint/__tests__/rule-missing-colors-load.bats`

```
PASS — no COLORS usage → no violation
PASS — COLORS[ with colors-load-definitions anywhere → no violation
PASS — ${(k)COLORS} with colors-load-definitions → no violation
PASS — COLORS[ only in a comment → no violation (comment lines skipped)
PASS — disable comment above first trigger line → no violation

FAIL — COLORS[ without colors-load-definitions → violation at first trigger line
FAIL — ${(k)COLORS} without colors-load-definitions → violation at first trigger line
FAIL — shebang script with COLORS[ and no loader → violation (scripts are in scope)
```

## Done when

- [ ] `rule-missing-colors-load.zsh` exists and is registered in `zsh-lint-custom.zsh`
- [ ] All behavioral tests pass
- [ ] `git-file-lint` clean on all modified files
- [ ] No regressions: `git-branch-color`, `colorize`, and `scripts/bin/colors` all pass the new rule after their fixes
- [ ] `colors-build` passes with its disable comment in place
