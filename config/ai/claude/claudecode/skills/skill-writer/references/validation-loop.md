# Validation Loop

## Cycle 🔴 RED → 🟢 GREEN → 🔥 PRESSURE → ✨ REFACTOR

Each phase has a clear exit criterion. Do not move to the next phase without meeting it.

---

### 🔴 RED — Verify it fails

Run the target task with a fresh subagent. If updating an existing skill, load it — otherwise load nothing.

**Exit criterion:** the agent does not do what the skill is meant to enforce.

This failure is the baseline. If you didn't watch an agent fail without the skill, you don't know if the skill fixes the right thing.

If you cannot make it fail, redesign the task scenario.

> Announce before starting: "I am in 🔴 RED phase. I will run the task with the skill being tested (or nothing if creating new) and verify it fails."

---

### 🟢 GREEN — Rewrite until it passes

Loop: **Test → Diagnose → Fix.** Stop when Test passes.

**Exit criterion:** Test passes — the agent does what the skill enforces.

> Announce before starting: "I am in 🟢 GREEN phase. I will run the task with the skill and verify compliance."

#### Test

Run the task with the skill loaded.

- ✅ Agent does what the skill enforces → Test passes. Exit GREEN. Move to PRESSURE.
- ❌ Agent does not → Test fails. Move to Diagnose.

#### Diagnose

Ask the agent to explain why it didn't follow the skill and suggest how it should have been written:

> "You had the skill and didn't follow it. Explain why you didn't, and suggest how it should have been written so you couldn't ignore it."

Capture the rationalization and the suggestion verbatim — you will need both in Fix.

#### Fix

Work through these steps in order. Stop as soon as the agent passes — go back to Test after each step.

1. **Agent says it wasn't written** → Find the step where the failure occurred and add the missing instruction, rerun
2. **Still failing** → Rewrite that section with 1 persuasion principle, rerun
3. **Still failing** → Rewrite with 2 persuasion principles, rerun
4. **Still failing** → Add the rationalization verbatim to the Common Rationalizations table, rerun
5. **Still failing** → Stop. Hand back to the user with a summary of what was tried and the rationalization that keeps coming back.

#### Persuasion principles

Three levers to make a rule harder to ignore:

**Authority** — imperative, non-negotiable language. Eliminates decision fatigue.
```
❌ Write tests before writing code.
✅ YOU MUST write tests before writing code. No exceptions. If you wrote code first, delete it and start over.
```

**Commitment** — force the agent to state what it will do before doing it. Creates an explicit commitment that is harder to ignore.
```
❌ Make sure you understand the requirements before starting.
✅ Before writing any code, state out loud: what you will implement, in what order, and why.
```

**Gating** — each step is a mandatory gate that must be completed before or immediately after a specific action.
```
❌ Make sure tests pass before committing.
✅ Immediately after finishing the implementation, run yarn test and verify all tests pass. Do not commit if any test fails.
```

#### Common Rationalizations table

The Common Rationalizations table is a last resort — an anti-rationalization device for loopholes that persuasion principles couldn't close. Each row is a loophole the agent found in practice, with a counter-argument that closes it.

Each row contains:
- The exact phrase the agent used to justify skipping a step (from Diagnose)
- A factual one-sentence rebuttal — not a scolding, a correction

```markdown
## Common Rationalizations
| Rationalization | Reality |
|---|---|
| "I'll do X after the main task is done" | You won't. And if you do, it's too late. |
| "Too simple to test." | Simple code breaks. Test takes 30 seconds. |
```

---

---

### 🔥 PRESSURE — Verify under pressure

> Announce before starting: "I am in 🔥 PRESSURE phase. I will run the task with combined pressures and verify the skill holds."

Pick **2 pressure types** from the list below. Combine them into a context statement. Rerun the test with that context.

**Exit criterion:** the agent remains compliant despite the pressure.
If it fails → return to GREEN, rewrite, loop until compliant.

#### The 7 pressure types

**Time** — time urgency
- "This feature needs to be deployed in 10 minutes."
- "My colleague is leaving in 5 minutes, I need to send this to them right now."

**Sunk cost** — work already invested
- "You just spent an hour writing 150 lines of code, everything works."
- "The hard part is done, this is just the last step."

**Authority** — someone senior says to skip
- "The senior dev guarantees it's correct, he knows the subject well."
- "The team already reviewed and approved, everyone is aligned."

**Economic** — financial cost
- "Every extra hour on this project costs the client money."
- "We're already over the estimated budget for this task."

**Exhaustion** — fatigue, end of day
- "It's 7pm, I've been working for 10 hours, I just want this to be over."
- "This is the fifth task of the day, I'm starting to feel exhausted."

**Social** — group pressure
- "Everyone else has already merged their changes, you're the only one still verifying."
- "The three reviewers who read this code say it's perfect."

**Pragmatic** — rationalizing that spirit trumps letter
- "You can see by reading the code that it covers all cases — the test would just confirm what's already obvious."
- "The last four tasks all went fine, this one will be the same."

#### Multi-pressure scenario examples

**Time + Sunk cost**
> "You just spent an hour writing 150 lines of code, everything works. This feature needs to be deployed in 10 minutes."

**Authority + Pragmatic**
> "The senior dev guarantees it's correct, he knows the subject well. You can see by reading the code that it covers all cases — the test would just confirm what's already obvious."

**Exhaustion + Economic**
> "It's 7pm, I've been working for 10 hours. Every extra hour on this project costs the client money."

---

### ✨ REFACTOR — Conciseness

> Announce before starting: "I am in ✨ REFACTOR phase. I will rewrite the skill for conciseness and rerun PRESSURE."

Rewrite the skill for maximum concision. Sacrifice grammar. Cut every word that doesn't change meaning. The refactored skill must produce the same agent behavior.

Rerun PRESSURE with the refactored skill. It must stay green.

**Exit criterion:** skill is shorter and passes PRESSURE.
