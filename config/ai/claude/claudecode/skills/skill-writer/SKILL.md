---
name: skill-writer
description: Use when creating or updating a discipline-enforcing skill.
---

# Skill Writer

## Overview

Creates discipline-enforcing skills that make agents comply with a process under pressure. Follows a TDD cycle: see the agent fail first, write the skill, verify compliance.

## Core Workflow

### Step 1 — Understand the goal

Ask the user questions one at a time until shared understanding is reached. Questions are about *what* the skill should enforce, not how to encode it. Exit when you can answer: what behavior should the agent follow, and in what situations?

### Step 2 — Write the skill

Create `$SKILL_DIR/<skill-name>/SKILL.md` following this structure:

```markdown
---
name: <skill-name>
description: Use when <triggering conditions>. Third person, max 1024 chars.
---

# Skill Name

## Overview
Goal in 1-2 sentences.

## Core Workflow
Sequential steps. Each step states its goal, then prescribes exact behavior.
Reference `references/*.md` for domain-specific details — open when needed.
Flowcharts only for non-obvious decision trees.

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| Excuse agents use to skip steps | Why the excuse is wrong |

## Checklist
- [ ] Verifiable exit criterion with required evidence
```

Default output location: `/home/tim/.oroshi/config/ai/claude/claudecode/skills/` unless specified otherwise.

**References:**
- `references/validation-loop.md` — Open when running the TDD cycle (RED/GREEN/PRESSURE/REFACTOR): pressure scenario construction, persuasion principles, meta-test technique.
- `references/claude-frontmatter-docs.md` — Open when you need a quick syntax lookup (frontmatter fields, string substitutions, dynamic context injection, invocation control).
- `references/claude-full-docs.md` — Open when you need the full official documentation (skill lifecycle, advanced patterns, troubleshooting, subagents, permissions).

### Step 3 — Review with user

Present the draft. User validates the high-level goal only — did their intent get captured correctly? Implementation details are not their concern.

### Step 4 — Test (TDD)

See `references/validation-loop.md` for the full cycle.

**Iron Law: NO SKILL WITHOUT A FAILING TEST FIRST**

- **RED** — Run the target task with a fresh subagent, no skill loaded. Document exact failures and rationalizations verbatim.
- **GREEN** — Load the skill. Run same task. If agent still fails, rewrite and retry. Repeat until compliant.
- **PRESSURE** — Run again with combined pressures (time, sunk cost, exhaustion). Must stay green. Failures → add to Common Rationalizations.
- **REFACTOR** — Tighten the skill for token efficiency. Re-run PRESSURE. Must stay green.

Each test uses a fresh subagent with no inherited context.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The skill is clear enough, no need to test" | Clear to you ≠ clear to an agent under pressure. Test it. |
| "I'll test after adding a few more sections" | Untested sections are untested code. RED first, always. |
| "The user approved it, that's enough validation" | User validates the goal. TDD validates the behavior. |
| "It's just a small update, no need to re-test" | Any edit can introduce a loophole. PRESSURE after every change. |

## Checklist

- [ ] User confirmed the skill captures their intent
- [ ] RED phase ran — failure documented verbatim
- [ ] GREEN phase passed — agent complies with skill loaded
- [ ] PRESSURE phase passed — agent complies under combined pressures
- [ ] REFACTOR done — skill is under 250 words and PRESSURE still passes
