## TLDR

Implement a custom zshlint rule (`missingIconsLoad`) that flags any ZSH file that accesses `$ICONS[...]` without calling `icons-load-definitions`.

## Background

Design decisions reached via grill-me (issue 12):

| Decision | Outcome |
|---|---|
| Check scope | All files zshlint processes — no filtering by extension or shebang. Same as every other zsh-lint rule. |
| Trigger patterns | `ICONS[` (subscript access, e.g. `$ICONS[git-branch]`, `${ICONS[tab]}`) and `${(k)ICONS}` (key enumeration). NOT `${#ICONS}` — used as a guard, not a dependency. |
| Detection strategy | Check for `icons-load-definitions` anywhere in the file (not positional). Report at the **first trigger line**, not line 1, so the existing `# zsh-lint disable=missingIconsLoad` mechanism works. |
| Exceptions | None hardcoded — use `# zsh-lint disable=missingIconsLoad` on the line above the first trigger. |
| Error message | "add 'icons-load-definitions' at top of file (after argument parsing if any)" |
| File | Separate file, parallel to `rule-missing-colors-load.zsh` |

## Implementation

### 1. New rule file

Create `scripts/bin/zsh/zsh-lint/__rules/rule-missing-icons-load.zsh`:

```zsh
# Custom Rule: zshLintRule_missingIconsLoad
# Detects functions/scripts that access $ICONS[] without calling icons-load-definitions
zshLintRule_missingIconsLoad() {
  local code='missingIconsLoad'
  local msg="add 'icons-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if icons-load-definitions is already present
  [[ "$content" =~ 'icons-load-definitions' ]] && return 0

  # Find first trigger line (ICONS[ subscript or ${(k)ICONS} enumeration)
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( lineNum++ ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ 'ICONS\[' || "$line" =~ '\$\{(\([^)]*\))?ICONS\}?' ]]; then
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
- `source "${_zshLintRulesDir}/rule-missing-icons-load.zsh"` in the source block
- `zshLintRule_missingIconsLoad` in the `lint-custom-run` call

### 3. Fix existing violators

There are two categories of violators:

**A. Autoloaded functions — add `icons-load-definitions` call**

These are called independently (including in tests) and must declare the dependency:

Run the rule after implementation to get the full list. Known examples at time of writing:

| File | Pattern |
|---|---|
| `tools/term/zsh/config/functions/autoload/git/branch/git-branch-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/branch/git-branch-list` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/branch/git-branch-list-remote` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/remote/git-remote-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/remote/git-remote-list` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/submodule/git-submodule-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/tag/git-tag-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-list` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/yarn/link/yarn-link-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/yarn/package/yarn-package-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/docker/container/docker-container-colorize` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/fly/fly-app-list` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/node/node-version-list` | Add `icons-load-definitions` |
| `tools/term/zsh/config/functions/autoload/fzf/*/fzf-*-options` | Add `icons-load-definitions` (all fzf options functions) |
| `tools/term/zsh/config/functions/autoload/completion/complete-git-worktrees*` | Add `icons-load-definitions` |
| `tools/term/zsh/config/completion/compdef/_git-*` | Add `icons-load-definitions` |
| `tools/term/zsh/config/completion/compdef/_docker-*` | Add `icons-load-definitions` |
| `tools/term/zsh/config/completion/compdef/_yarn-*` | Add `icons-load-definitions` |

**B. Standalone scripts — covered by issue 15**

`scripts/bin/statusbar/statusbar-{cpu,ram,ping}` currently `source` icons.zsh directly. Issue 15 migrates them to `icons-load-definitions`. This issue depends on issue 15 being done first, or accepts that those 3 files will still violate until issue 15 runs.

**C. Sourced config files — add disable comment**

These files are always loaded after `theming/index.zsh` in the normal shell startup sequence. They do not need the explicit call:

| File | Reason |
|---|---|
| `tools/term/zsh/config/prompt/git.zsh` | Sourced by theming bootstrap |
| `tools/term/zsh/config/prompt/exit-code.zsh` | Sourced by theming bootstrap |
| `tools/term/zsh/config/prompt/node.zsh` | Sourced by theming bootstrap |
| `tools/term/zsh/config/prompt/ruby.zsh` | Sourced by theming bootstrap |
| `tools/term/zsh/config/prompt/yarn.zsh` | Sourced by theming bootstrap |
| `tools/term/zsh/config/prompt/python.zsh` | Sourced by theming bootstrap |
| `tools/term/zsh/config/tools/fzf.zsh` | Sourced config file |

Add `# zsh-lint disable=missingIconsLoad` on the line above each file's first `ICONS[` access.

### 4. No false positives expected

`theming/icons.zsh` defines the array but does not subscript it — no disable needed.
`icons-load-definitions` itself checks `${#ICONS}` (not a trigger) then sources the file — no disable needed.

## Behavioral Tests

Tests live next to the rule file: `scripts/bin/zsh/zsh-lint/__tests__/rule-missing-icons-load.bats`

```
PASS — no ICONS usage → no violation
PASS — ICONS[ with icons-load-definitions anywhere → no violation
PASS — ${(k)ICONS} with icons-load-definitions → no violation
PASS — ICONS[ only in a comment → no violation (comment lines skipped)
PASS — disable comment above first trigger line → no violation

FAIL — ICONS[ without icons-load-definitions → violation at first trigger line
FAIL — ${(k)ICONS} without icons-load-definitions → violation at first trigger line
FAIL — shebang script with ICONS[ and no loader → violation (scripts are in scope)
```

## Done when

- [ ] `rule-missing-icons-load.zsh` exists and is registered in `zsh-lint-custom.zsh`
- [ ] All behavioral tests pass
- [ ] `git-file-lint` clean on all modified files
- [ ] No regressions: all autoloaded function fixes and disable comments pass the new rule
- [ ] All prompt/config files with disable comments pass the new rule
