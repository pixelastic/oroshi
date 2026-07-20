## Problem Statement

The three language-specific writer skills (zsh-writer, js-writer, python-writer) should all follow a consistent RED-GREEN-REFACTOR-LINT TDD structure, but zsh-writer is missing a Refactor step. Its current Step 3 mixes "make it work" and "apply patterns" into one step, while js-writer and python-writer correctly separate them. Additionally, code-writer's language list is incomplete (missing python-writer) and doesn't mention the TDD workflow expectation.

## Solution

1. Split zsh-writer's Step 3 into two steps: GREEN (minimal code to pass) and REFACTOR (apply patterns from the table), making Lint become Step 5.
2. Align python-writer's "Make it work" step wording with js-writer for consistency.
3. Add python-writer to code-writer's language list and add a one-liner about the RED-GREEN-REFACTOR-LINT workflow expectation.

## User Stories

1. As an AI agent using zsh-writer, I want a separate Refactor step after making the test pass, so that I don't conflate "get it working" with "apply style patterns."
2. As an AI agent using zsh-writer, I want the Refactor step to re-run tests, so that I confirm pattern application didn't break behavior.
3. As an AI agent reading code-writer, I want to see all three language skills listed, so that I pick the right one regardless of language.
4. As an AI agent reading code-writer, I want to know the expected TDD workflow structure, so that I follow it even when a language-specific skill doesn't exist yet.
5. As a skill author, I want all writer skills to follow the same step structure, so that adding a new language writer has a clear template to follow.
6. As an AI agent using python-writer, I want the "Make it work" step to use the same wording as js-writer, so that the instruction is unambiguous across skills.

## Implementation Decisions

- The canonical step order is: Place file -> (language gate?) -> RED (failing test) -> GREEN (make it work) -> REFACTOR (patterns, tests still pass) -> LINT (deterministic checks)
- zsh-writer's new Step 3 (Make it work) mirrors js-writer's wording: "Write the simplest code that makes the test pass. No patterns yet — just correct behavior."
- zsh-writer's new Step 4 (Refactor) gets the pattern table and code example moved from old Step 3, plus a "run bats" reminder to confirm tests still pass
- zsh-writer's Lint becomes Step 5 (content unchanged)
- zsh-writer's Checklist gains "Tests still pass after refactor"
- python-writer's Step 4 (Make it work) body text changes from "Write the simplest code that makes the test green. Don't optimize yet." to match js-writer: "Write the simplest code that makes the test pass. No patterns yet — just correct behavior."
- code-writer's Language-Specific Skills section adds python-writer and a one-sentence note about the RED-GREEN-REFACTOR-LINT workflow

## Testing Decisions

No tests. These are skill definition files (markdown configuration), not code. The artifact is the file itself.

## Out of Scope

- Modifying js-writer or tdd skills (already correct)
- Adding new patterns or references to zsh-writer's pattern table
- Restructuring the tdd skill to reference writer skills
- Creating a shared template or inheritance mechanism for writer skills
