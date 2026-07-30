## Problem Statement

The Spec agent in the `/review` skill oversteps its role. Instead of checking "does the code do what the spec asks?", it flags code quality and correctness issues — which is the Code Review agent's job. This produces false positives and blurs the two-axis separation that makes the review skill useful.

## Solution

Tighten both review sub-agent briefs with explicit scope boundaries, rename the Standards agent to "Code Review" for clarity, and add reinforcement layers (Common Rationalizations + Checklist) to keep each agent in its lane.

## User Stories

1. As a developer running `/review`, I want the Spec agent to only flag spec conformance issues, so that I don't waste time triaging false positives about code style
2. As a developer running `/review`, I want the Code Review agent to only flag code quality issues, so that spec conformance findings don't leak into the wrong section
3. As a developer reading the review output, I want "Code Review" and "Spec Review" headings, so that I immediately understand what each axis checks
4. As a developer reading an agent brief, I want a clear Scope / Out of scope section, so that I can predict what the agent will and won't flag
5. As a developer maintaining the review skill, I want symmetric structure across both agent briefs, so that adding a new rationalization or checklist item follows the same pattern
6. As a developer reading the Spec agent's output, I want every finding to cite a specific spec line, so that I can verify the finding against the source
7. As a developer reading the Code Review agent's output, I want every finding to cite a specific standard source, so that I can verify the finding against the documented rule

## Implementation Decisions

- **Rename Standards → Code Review:** File `standards-agent.md` becomes `code-agent.md`. Header becomes "Code Review Agent". All references in `SKILL.md` updated.
- **Rename Specs → Spec (singular):** File `specs-agent.md` becomes `spec-agent.md`. Header becomes "Spec Review Agent". All references in `SKILL.md` updated.
- **Three-layer reinforcement per agent:** Each brief gets (1) Scope + Out of scope sections after the preamble, (2) a Common Rationalizations table with one entry — the temptation to cross into the other agent's territory, (3) a Checklist for self-verification.
- **Scope boundaries are abstract categories, not concrete examples:** e.g. "Code style, naming, conventions" rather than "flagging `local` usage". Avoids over-indexing on specific cases.
- **Fix step ordering in Spec agent:** Current Steps are numbered 1, 3, 2. Correct to 1, 2, 3.
- **SKILL.md heading rename:** "Standards" → "Code Review", "Spec" stays "Spec Review". The aggregation step references both by new names.

## Testing Decisions

No automated tests. These are prompt files — validation is manual by running `/review` on a real diff and checking that each agent stays in its lane.

## Out of Scope

- Changing the review orchestration logic in SKILL.md (steps, parallel spawning, aggregation)
- Adding more than one rationalization entry per agent (start minimal, iterate based on observed drift)
- Modifying the `review-diff` script or any tooling
- Adding automated tests for prompt quality

## Further Notes

The two false positives that motivated this change are documented in the sidequest brief at `/tmp/oroshi/claude/sidequests/spec-agent-scope.md`. If further drift is observed after this change, add targeted rationalization entries rather than rewriting the scope sections.
