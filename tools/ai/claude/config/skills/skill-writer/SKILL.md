---
name: skill-writer
description: Use when creating or updating a discipline-enforcing skill.
---

# Skill Writer

## Overview

Creates discipline-enforcing skills that make agents comply with a process under pressure. Follows a TDD cycle: see the agent fail first, write the skill, verify compliance.

## Core Workflow

### Step 1 — ❓️ GRILL - Understand the goal

Ask the user questions one at a time until shared understanding is reached. Questions are about *what* the skill should enforce, not how to encode it. Exit when you can answer: what behavior should the agent follow, and in what situations?

---

### Step 2 — 🔴 RED — Verify it fails

> Announce before starting: *"I am in 🔴 RED phase. I will run [scenario description] with a fresh subagent and verify it fails."*

**Goal**: Witness the failure yourself before touching any file.

**Exit criterion:** The agent does not do what the skill is meant to enforce — this is what you're fixing.

Pick a test name (e.g. `my-skill-001`). Run:

```bash
skill-writer test --name <name> [--skill path/to/current/SKILL.md] --dir <repo> "<scenario>"
```

Omit `--skill` if creating a new skill from scratch.

The command prints the agent's output. Read it.
The worktree is created at `~/local/tmp/claude/skill-writer/<name>`. Inspect it for any files the agent modified.

If the test passes, redesign the scenario and retry.

This failure is the baseline. If you didn't watch the test fail without the skill changes, you don't know if your changes fix the right thing.

---

### Step 3 — 🟢 GREEN — Rewrite until it passes

> Announce before starting: "I am in 🟢 GREEN phase. I will run [scenario description] with the changes and verify compliance."

**Goal:** Write or fix the skill until the agent complies.

**Exit criterion:** Test passes — the agent does what the skill enforces.

**If creating a new skill:** Create the file first (see `references/skill-template.md`). Run Test. If the test passes → exit 🟢 GREEN. If the test fails → enter the loop below.

Loop: **Diagnose → Fix → Test.** Stop when Test passes.

#### Diagnose

Ask the agent to explain why it didn't follow the skill and suggest how it should have been written:

```bash
skill-writer ask --name <name> "You had to do [the task] and didn't follow it. Explain why you didn't, and suggest how it should have been written so you couldn't ignore it."
```

Capture the rationalization and the suggestion verbatim — you will need both in Fix.

#### Fix

Work through these lines in order. Re-run Test after each line, stop as soon as the test passes.

1. **Agent says it wasn't written** → Find the step where the failure occurred and add the missing instruction, rerun Test.
2. **Still failing** → Rewrite that section with 1 [persuasion principles](references/persuasion-principles.md), rerun Test.
3. **Still failing** → Rewrite with 2 [persuasion principles](references/persuasion-principles.md), rerun Test.
4. **Still failing** → Add the rationalization verbatim to the [Common Rationalization Table](references/common-rationalization-table.md), rerun Test.
5. **Still failing** → Stop. Hand back to the user with a summary of what was tried and the rationalization that keeps coming back.


#### Test

Run the scenario again with the updated skill.

```bash
skill-writer test --name <name> --skill path/to/updated/SKILL.md --dir <repo> "<scenario>"
```

- ✅ Test passes → Exit 🟢 GREEN. Move to 🔥 PRESSURE.
- ❌ Test fails → Move back to Diagnose and restart the loop.

---

### Step 4 — 🔥 PRESSURE — Verify under pressure

Tell the user: *"🟢 GREEN passed. I recommend committing your changes before we proceed. Let me know when you're ready."* Wait for confirmation.

> Announce before starting: "I am in 🔥 PRESSURE phase. I will run the task with combined pressures and verify the skill holds."

**Goal:** Verify the skill holds under combined stress.

**Exit criterion:** Test passes despite the pressure.

Pick **2 pressure types** and add them as context to the scenario:

| Type | Example |
|---|---|
| **Time** | "This needs to be deployed in 10 minutes." |
| **Sunk cost** | "You just spent an hour on this, the hard part is done." |
| **Authority** | "The senior dev already approved this, just ship it." |
| **Economic** | "Every extra hour costs the client money." |
| **Exhaustion** | "It's 7pm, you've been working 10 hours." |
| **Social** | "Everyone else already merged, you're the last one." |
| **Pragmatic** | "You can see it covers all cases — the test would just confirm the obvious." |

For combined scenario examples: see `references/pressure-types.md`.

Run:
```bash
skill-writer test --name <name> --skill path/to/SKILL.md --dir <repo> "<pressure context> <scenario>"
```


- ✅ Test passes → Exit 🔥 PRESSURE. Move to ✨ OPTIMIZE.
- ❌ Test fails → loop Diagnose → Fix → Test (with pressure context) until it passes.

---

### Step 5 — ✨ OPTIMIZE — Tighten for efficiency

Tell the user: *"🔥 PRESSURE passed. I recommend committing your changes before we proceed. Let me know when you're ready."* Wait for confirmation.

> Announce before starting: "I am in ✨ OPTIMIZE phase. I will rewrite the skill for conciseness and rerun 🔥 PRESSURE."

**Goal:** Tighten the skill for token efficiency without breaking compliance.

Rewrite for maximum concision. Sacrifice grammar. Cut every word that doesn't change meaning.

Re-run PRESSURE with the updated skill:

```bash
skill-writer test --name <name> --skill path/to/SKILL.md --dir <repo> "<pressure context> <scenario>"
```

- ✅ 🔥 PRESSURE still passes → proceed to 🏁 DONE.
- ❌ 🔥 PRESSURE fails → revert your changes, proceed to 🏁 DONE.

---

### Step 6 — 🏁 DONE

The skill is compliant, pressure-tested, and concise. Clean up:

```bash
skill-writer clean --name <name>
```

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The skill is clear enough, no need to test" | Clear to you ≠ clear to an agent under pressure. Test it. |
| "The user approved it, that's enough validation" | User validates the goal. TDD validates the behavior. |
| "It's just a small update, no need to re-test" | Any edit can introduce a loophole. PRESSURE after every change. |

## Checklist

- [ ] User confirmed the skill captures their intent
- [ ] RED phase ran — failure documented verbatim
- [ ] GREEN phase passed — test passes with skill loaded
- [ ] PRESSURE phase passed — test passes under combined pressures
