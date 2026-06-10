## TLDR

Implement a custom zshlint rule (`missingProjectsLoad`) that flags any ZSH file that accesses `$PROJECTS[...]` without calling `projects-load-definitions`.

## Background

Design decisions reached via grill-me (issue 13):

| Decision | Outcome |
|---|---|
| Check scope | All files zshlint processes — no filtering by extension or shebang. Same as every other zsh-lint rule. |
| Trigger patterns | `PROJECTS[` (subscript access, e.g. `$PROJECTS[oroshi:icon]`, `${PROJECTS[name:path]}`) and `${(k)PROJECTS}` (key enumeration). NOT `${#PROJECTS}` — used as a guard, not a dependency. |
| Detection strategy | Check for `projects-load-definitions` anywhere in the file (not positional). Report at the **first trigger line**, not line 1, so the existing `# zsh-lint disable=missingProjectsLoad` mechanism works. |
| Exceptions | None hardcoded — use `# zsh-lint disable=missingProjectsLoad` on the line above the first trigger. |
| Error message | "add 'projects-load-definitions' at top of file (after argument parsing if any)" |
| File | Separate file, parallel to `rule-missing-colors-load.zsh` and `rule-missing-icons-load.zsh` |

## Implementation

### 1. New rule file

Create `scripts/bin/zsh/zsh-lint/__rules/rule-missing-projects-load.zsh`:

```zsh
# Custom Rule: zshLintRule_missingProjectsLoad
# Detects functions/scripts that access $PROJECTS[] without calling projects-load-definitions
zshLintRule_missingProjectsLoad() {
  local code='missingProjectsLoad'
  local msg="add 'projects-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if projects-load-definitions is already present
  [[ "$content" =~ 'projects-load-definitions' ]] && return 0

  # Find first trigger line (PROJECTS[ subscript or ${(k)PROJECTS} enumeration)
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( lineNum++ ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ 'PROJECTS\[' || "$line" =~ '\$\{(\([^)]*\))?PROJECTS\}?' ]]; then
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
- `source "${_zshLintRulesDir}/rule-missing-projects-load.zsh"` in the source block
- `zshLintRule_missingProjectsLoad` in the `lint-custom-run` call

### 3. No existing violators

All production files that access `$PROJECTS[...]` already call `projects-load-definitions`:

| File | Status |
|---|---|
| `tools/term/zsh/config/functions/autoload/project/context-badge` | Already compliant |
| `tools/term/zsh/config/functions/autoload/project/project-exists` | Already compliant |
| `tools/term/zsh/config/functions/autoload/project/project-name` | Already compliant |
| `tools/term/zsh/config/functions/autoload/project/project-path` | Already compliant |
| `tools/term/zsh/config/prompt/yarn.zsh` | Already compliant |
| `tools/term/zsh/config/functions/autoload/completion/complete-jumps` | Already compliant |

### 4. Disable false positives

These files have `PROJECTS[` in non-access contexts and need a disable comment:

| File | Location | Reason |
|---|---|---|
| `tools/term/zsh/config/theming/projects-build` | Above first jq heredoc line containing `PROJECTS[` | `PROJECTS[` appears inside a jq string that generates the dist file — not a ZSH access |
| `tools/term/zsh/config/theming/dist/projects.zsh` | Above first `PROJECTS[` line | Generated file that *defines* array entries (`PROJECTS[key]=value`) — not a consumer |
| `tools/term/zsh/config/theming/__tests__/projects-build.bats` | Above the heredoc block containing `PROJECTS[` | `PROJECTS[` is inside a heredoc string written to a temp script — not a ZSH access in this file |

Note: `tools/term/zsh/config/theming/src/projects-list.zsh` also defines array entries but uses `declare -A` (bash syntax) — check whether zshlint processes it; add disable comment if needed.

## Behavioral Tests

Tests live next to the rule file: `scripts/bin/zsh/zsh-lint/__tests__/rule-missing-projects-load.bats`

```
PASS — no PROJECTS usage → no violation
PASS — PROJECTS[ with projects-load-definitions anywhere → no violation
PASS — ${(k)PROJECTS} with projects-load-definitions → no violation
PASS — PROJECTS[ only in a comment → no violation (comment lines skipped)
PASS — disable comment above first trigger line → no violation

FAIL — PROJECTS[ without projects-load-definitions → violation at first trigger line
FAIL — ${(k)PROJECTS} without projects-load-definitions → violation at first trigger line
FAIL — shebang script with PROJECTS[ and no loader → violation (scripts are in scope)
```

## Done when

- [ ] `rule-missing-projects-load.zsh` exists and is registered in `zsh-lint-custom.zsh`
- [ ] All behavioral tests pass
- [ ] `git-file-lint` clean on all modified files
- [ ] No regressions: all existing compliant files pass the new rule
- [ ] `projects-build`, `dist/projects.zsh`, and `projects-build.bats` pass with their disable comments in place
