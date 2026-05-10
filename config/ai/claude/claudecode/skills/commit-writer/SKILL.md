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

**HARD LIMIT: First line MUST be ≤72 characters. Count them. No exceptions.**

If your first line is over 72 characters:
- Move scope detail to the body
- Abbreviate — be ruthless
- Split the change into multiple commits if needed
- DO NOT exceed 72 chars "just this once"

```
# ❌ Too long (82 chars):
feat(auth): add email validation to registration and password reset endpoints

# ✅ Fixed (54 chars) — detail moved to body:
feat(auth): add email validation to auth endpoints
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change that neither fixes a bug nor adds a feature
- `perf` — Performance improvement
- `test` — Adding or updating tests
- `docs` — Documentation only
- `style` — Visual change only
- `chore` — Tooling, dependencies, config

**Body:** Why this change matters. Include context, decisions, and reasoning not visible in the code itself. The "what" is already in the diff—explain the "why" instead. Link to bug numbers, benchmark results, or design docs where relevant. Acknowledge approach shortcomings when they exist. If the header is self-explanatory, omit the body entirely.

**Attribution:** Do **not** include the "Generated with Claude Code", "Co-Authored-By: Claude" or the 🤖 robot emoji attribution.

**Anti-patterns:** "Fix bug," "Fix build," "Add patch," "Moving code from A to B," "Phase 1," "Add convenience functions."

## Descriptive Messages

Commit messages explain the *why*, not just the *what*:

```
# Good: Explains why, not what
feat: add email validation to registration endpoint

Prevents invalid email formats from reaching the database.
Uses Zod schema validation at the route handler level,
consistent with existing validation patterns in auth.ts.

# Good: Header is self-explanatory, no body needed
chore(deps): update eslint from 8.2.0 to 8.3.0

# Bad: Body describes implementation details visible in the diff
refactor(git): wrap commit messages at 72 characters

Stores the output from claude-print in a variable, then wraps it
at 72 characters using fold -s (preserving word boundaries) before
displaying.

# Good: Same change, but body explains why
refactor(git): wrap commit messages at 72 characters

Ensures generated commit messages follow the standard
line length convention for better readability in git logs.

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
| "This commit is complex and needs a long first line" | Move detail to the body. The limit exists for git log readability. |

**EVERY rationalization has the same answer: Just output the message.**

## The Iron Law

**Violating the letter of these rules IS violating the spirit of these rules.**

Don't try to find creative ways around the format requirement. The format exists for automation. Breaking it breaks the user's workflow.
