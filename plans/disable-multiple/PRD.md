# PRD: Multi-rule disable comments for zshlint and batslint

## Problem

`zshlint` and `batslint` support suppressing a single lint rule on the next line via a disable comment:

```zsh
# zsh-lint disable=noGroupedLocals
local a b
```

When multiple rules trigger on the same line, there is no way to suppress them with a single comment. Users must stack multiple disable comments, which is verbose and clutters the code. The shared engine (`lint-custom-run`) only matches a single rule code per comment, so the multi-rule case is simply unsupported today.

## Solution

Extend the disable comment format to accept a comma-separated list of rule codes:

```zsh
# zsh-lint disable=rule1,rule2,rule3
```

The single-rule format (`# zsh-lint disable=rule1`) continues to work unchanged. The change is confined to the shared engine `lint-custom-run` — both linters inherit the fix automatically.

**New format rules:**
- No spaces around commas: `rule1,rule2` only, not `rule1, rule2`
- Unknown rule codes in the list are silently ignored
- Scope is still the single line immediately following the comment

## User Stories

- As a zsh developer, I want to write `# zsh-lint disable=rule1,rule2` above a line that triggers two rules, so that both violations are suppressed without stacking two disable comments.
- As a bats developer, I want the same multi-rule disable syntax to work in `.bats` files via `# bats-lint disable=rule1,rule2`.
- As an existing user, I want my current `# zsh-lint disable=singleRule` comments to keep working without any changes.

## Implementation Decisions

- **Single change point:** `lint-custom-run:60` — the one-liner regex match is replaced with a parse-then-membership-check:
  1. Match `# <prefix> disable=<list>` from `lineAbove` (same prefix, now capturing the full list)
  2. Split `<list>` on `,`
  3. Check if `ruleCode` is a member of the resulting array
- **No changes** to `zsh-lint`, `bats-lint`, rule files, or disable-prefix configuration — the interface is unchanged
- **Implementation in zsh:** use `${(@s:,:)list}` to split and `${array[(Ie)value]}` for membership test

## Testing Decisions

Tests via linter entry points only (no direct `lint-custom-run` invocation in tests).

**`zsh-lint-custom.bats`** — extend with:
- `disable=A,B` suppresses both rules on the next line (both violations absent from output)
- `disable=A,B` does not suppress a third rule that also triggers on that line

**`bats-lint-custom.bats`** — extend with:
- `disable=noRunZsh,noInlineFunction` suppresses both rules on the next line
- `disable=noRunZsh,noInlineFunction` does not suppress a third unrelated rule

Existing single-rule tests are not modified — they continue to cover backward compatibility.

## Out of Scope

- Spaces around commas (`rule1, rule2`)
- Disabling rules across multiple lines (block-level suppression)
- Warning on unknown rule codes in the disable list
- Any change to `zsh-lint`, `bats-lint`, rule files, or disable-prefix configuration
