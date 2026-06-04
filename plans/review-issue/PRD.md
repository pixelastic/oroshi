## Problem Statement

When the `ralph` skill triggers the `review` skill mid-session, the Spec agent reviews against the full PRD instead of the active issue file. This produces false positives: modules scoped to future issues are flagged as missing from the current diff.

Additionally, the `review` skill has no formal argument contract — args are inferred from natural language only, with no way to pass structured named parameters programmatically.

## Solution

Define a formal named-parameter interface for the `review` skill (`issue:` and `ref:`). Ralph passes the active issue path and diff base explicitly. The Spec agent uses the provided issue path directly, scoping its review to what was actually in-scope for this session.

## User Stories

1. As Ralph, I want to pass the active issue path to the review skill, so that the Spec agent reviews against the current issue and not the full PRD.
2. As Ralph, I want to pass the diff base explicitly, so that the review is always scoped to dirty WIP changes.
3. As a developer calling `/review` manually, I want to pass `issue:<path>` and `ref:<value>` as named params, so that I can control both axes of the review precisely.
4. As a developer calling `/review` manually without args, I want the agent to ask me what I mean (with a recommendation), so that I never get a silently wrong review.
5. As a developer, I want `ref:dirty` to mean "compare against the dirty working tree", so that the WIP case has an explicit, unambiguous name.
6. As a developer, I want `ref:worktree` to continue working as before, so that worktree-based reviews are not broken.
7. As a developer, I want the Spec agent to report "no spec available" when no issue path is provided, so that spec failures are explicit rather than silently reviewing the wrong document.

## Implementation Decisions

- **Named-param contract for `review`:** The review skill's Step 1 is rewritten around two named tokens: `issue:<path>` (the spec file to review against) and `ref:<git-ref>` (the diff base). These tokens are parsed out of the args string before being forwarded to sub-agents.
- **`ref:` special values:** `ref:dirty` maps to no args for `review-diff` (dirty working tree diff). `ref:worktree` continues to work as before. Any other value is passed through as a git ref.
- **Backward-compatible example table:** The existing table of user-facing phrases is kept but reframed as example values for `ref:`. No existing call pattern breaks.
- **Missing args → ask, not infer:** If `issue:` or `ref:` is absent and cannot be determined from context, the review agent asks the user explicitly. It does not silently fall back to state.json or PRD.
- **Ralph passes explicit named params:** Ralph Step 4 calls the review skill with `issue:<absolute_path_from_ralph_start> ref:dirty`. The issue path comes directly from the `ralph-start` JSON output, already available in Ralph's context.
- **Spec agent simplified:** `specs-agent.md` Step 2 is simplified to use the provided issue path directly. If no path is provided, it reports "no spec available" and stops. All inference logic is removed.
- **No changes to `review-diff`:** The underlying script is unchanged. The review skill translates `ref:dirty` → no args before calling it.

## Testing Decisions

No automated tests. These are LLM instruction documents (`.md` skill files). Behavioral correctness is verified by running `ralph` end-to-end and observing that the Spec agent scopes its review to the active issue file.

## Out of Scope

- Auto-detection of the active issue from `state.json` in either the review skill or the Spec agent.
- Passing a `prd:` named param (PRD path) — the Spec agent already falls back cleanly to "no spec available" when no issue is given.
- Changes to `review-diff` or any other underlying script.
- Any new test harness for skill markdown files.

## Further Notes

The `issue:` token was chosen over `spec:` to match the domain vocabulary (`state.json` uses `"issue"`, ralph's output uses `"issue"`). The `ref:` token was chosen to be unambiguous — no git ref begins with `ref:`.
