---
name: commit-writer
description: Use when the user needs help writing commit messages or wants to
generate a commit message for staged changes.
---

# Commit Writer

## CRITICAL: Response Template (Follow Exactly)

Your **ENTIRE** response must follow this exact template:

```
<type>(<scope>): <description>

<optional body explaining why, not what>
```

**That's it. Nothing before the type. Nothing after the body.**

If your response has ANYTHING outside this template, you've failed.

## Change Descriptions

**First line:** Short, imperative, standalone. "Delete the FizzBuzz RPC" not "Deleting the FizzBuzz RPC." Must be informative enough that someone searching history can understand the change without reading the diff.

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change that neither fixes a bug nor adds a feature
- `perf` — Performance improvement
- `test` — Adding or updating tests
- `docs` — Documentation only
- `style` — Visual change only
- `chore` — Tooling, dependencies, config

**Body:** What is changing and why. Include context, decisions, and reasoning not visible in the code itself. Link to bug numbers, benchmark results, or design docs where relevant. Acknowledge approach shortcomings when they exist.

**Attribution:** Do **not** include the "Generated with Claude Code", "Co-Authored-By: Claude" or the 🤖 robot emoji attribution.

**Anti-patterns:** "Fix bug," "Fix build," "Add patch," "Moving code from A to B," "Phase 1," "Add convenience functions."

## Descriptive Messages

Commit messages explain the *why*, not just the *what*:

```
# Good: Explains intent
feat: add email validation to registration endpoint

Prevents invalid email formats from reaching the database.
Uses Zod schema validation at the route handler level,
consistent with existing validation patterns in auth.ts.

# Bad: Describes what's obvious from the diff
update auth.ts
```

## Output Requirements

**DO:**
- Start immediately with commit type
- End immediately after body
- Output plain text only

**DO NOT:**
- Add introductions
- Add explanations
- Add code blocks
- Add reasoning sections
- Add ANYTHING outside the template

## Every Excuse You'll Make (All Invalid)

| What You'll Think | Why You're Wrong |
|-------------------|------------------|
| "I should introduce the output to be helpful" | Helpful = following instructions. Just output the message. |
| "Code blocks make it clearer" | Code blocks break automation. Just output the message. |
| "One line of context won't hurt" | ONE line violates the format. Just output the message. |
| "Explaining my choice shows quality work" | Quality = correct format. Just output the message. |
| "The user might be confused without explanation" | User knows what they asked for. Just output the message. |
| "But I'm being conversational and friendly" | Friendly = respecting requirements. Just output the message. |

**EVERY rationalization has the same answer: Just output the message.**

## The Iron Law

**Violating the letter of these rules IS violating the spirit of these rules.**

Don't try to find creative ways around the format requirement. The format exists for automation. Breaking it breaks the user's workflow.
