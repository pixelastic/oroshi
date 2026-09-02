# Skill Template

## Default location

`~/.oroshi/tools/ai/claude/config/skills/<skill-name>/SKILL.md`

## Template

```markdown
---
name: <skill-name>
description: Use when <triggering conditions>. Third person, max 1024 chars.
---

# Skill Name

## Overview
Goal in 1-2 sentences.

## Core Workflow

### Step 1 — [Name]

**Goal:** [What this step achieves — one sentence.]

**Exit criterion:** [When to move to the next step — one sentence.]

[Instructions that prescribe exact behavior. Reference `references/*.md` for domain-specific details — open when needed. Flowcharts only for non-obvious decision trees.]

### Step 2 — [Name]

**Goal:** [What this step achieves — one sentence.]

**Exit criterion:** [When to move to the next step — one sentence.]

[Instructions, similar to Step 1.]

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| Excuse agents use to skip steps | Why the excuse is wrong |

## Checklist
- [ ] Verifiable exit criterion with required evidence
```

## References

- `references/claude-frontmatter-docs.md` — Quick syntax lookup: frontmatter fields, string substitutions, dynamic context injection, invocation control.
- `references/claude-full-docs.md` — Full official documentation: skill lifecycle, advanced patterns, troubleshooting, subagents, permissions.
