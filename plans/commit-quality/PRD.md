## Problem Statement

The `git-commit-message` script generates inconsistent and sometimes low-quality commit messages. Three patterns pollute the git history on main: plan-internal issue numbers leak into commit subjects (e.g. "mark issue 03 complete"), plan lifecycle commits are either missing or badly described, and the script always calls the Claude API even when the correct commit message is fully deterministic (plan deletion).

The root causes are upstream of the script itself: the ralph skill's COMMIT_HINT.md template encourages issue-centric language, the ralph SKILL.md conflates four distinct documentation sub-tasks into one step, the prd skill never writes a COMMIT_HINT.md for plan-creation commits, and no commit type exists for plan lifecycle events.

## Solution

Fix each root cause at its own layer:

1. Extract the COMMIT_HINT.md authoring instructions from the ralph skill into a dedicated reference file, reformulating the "Done" section to describe outcomes rather than issue status, and explicitly prohibiting issue numbers.
2. Restructure the ralph skill's documentation phase from one multi-part step into three sequential steps (update plan artifacts, write COMMIT_HINT, stop), making each step's exit criterion explicit.
3. Add a final step to the prd skill that writes a COMMIT_HINT.md at plan-creation time, so plan-creation commits travel through the `commitWithHint` path and produce a `plan(<slug>)` commit.
4. Add a deterministic plan-deletion strategy to the `git-commit-message` script: if the sentinel files (`PRD.md` and `state.json`) for a plan slug are both staged as deleted, return a hardcoded `plan(<slug>): delete completed artifacts` message without an API call.
5. Register `plan` as a valid commit type in both commit prompts for consistency.

## User Stories

1. As a developer reading `git log`, I want commit subjects to describe what was built, so that I can understand the history without access to deleted plan artifacts.
2. As a developer reading `git log`, I want plan-creation commits to have a clear `plan(<slug>)` type, so that I can trace the lifecycle of any feature from plan creation to completion.
3. As a developer reading `git log`, I want plan-deletion commits to have a matching `plan(<slug>)` type, so that creation and deletion form a visible pair in history.
4. As ralph, I want the COMMIT_HINT.md reference to explicitly tell me not to include issue numbers, so that I don't accidentally write "closed issue 03" in the hint.
5. As ralph, I want the COMMIT_HINT.md authoring step to be its own named step with a clear exit criterion, so that I can't accidentally skip it or conflate it with updating state.json.
6. As ralph, I want a separate step for logging skipped review feedback, so that the commit-hint step is not cluttered with review-log concerns.
7. As the prd skill, I want to write a COMMIT_HINT.md after creating the plan directory, so that the user's next commit is well-described without any extra effort.
8. As the `git-commit-message` script, I want to detect plan-deletion commits deterministically, so that I don't spend an API call on a message that is fully predictable.
9. As a developer staging a mixed commit (plan deletion + minor other changes), I want the commit message to reflect the plan deletion, so that the plan deletion is not buried under unrelated noise.
10. As a developer, I want both commit prompts to list `plan` as a valid type, so that the type system is consistent regardless of which strategy path is taken.

## Implementation Decisions

- The `plan` commit type is defined as: a commit whose primary purpose is creating or deleting a ralph plan directory. Scope is the plan slug (e.g. `plan(bats-shebang)`).
- Plan-deletion detection uses two sentinel files (`PRD.md` and `state.json`) that must **both** be staged as deleted for the same slug. A single sentinel deleted is not sufficient — it could be a partial cleanup.
- Plan-deletion detection applies even in mixed commits (plan deletion + other staged files). The plan deletion takes precedence and the hardcoded message is returned; other changes in the commit are not reflected in the subject line.
- The deterministic plan-deletion strategy short-circuits before the API call, returning the commit message directly.
- The COMMIT_HINT.md reference file lives in `ralph/references/` so it can be referenced by both the ralph skill and the prd skill using relative paths.
- The review-log.md format is extracted into `ralph/references/review-log.md` and referenced in ralph Step 7. Review-log is considered a plan artifact (committed to the repo), not an ephemeral file, so it belongs in Step 5 alongside state.json and GUIDANCE.md.
- The prd skill's new COMMIT_HINT step references the same `ralph/references/commit-hint.md` file to avoid duplicating the format specification.
- The ralph skill's step numbering changes from 6 steps to 8 steps: Setup / RED / IMPLEMENT / REVIEW & FIX / UPDATE PLAN ARTIFACTS / WRITE COMMIT HINT / LOG SKIPPED FEEDBACK / STOP.
- Step 5 (UPDATE PLAN ARTIFACTS) covers state.json, GUIDANCE.md, and review-log.md — all files that are committed to the plan directory in the repo.
- Step 6 (WRITE COMMIT HINT) covers COMMIT_HINT.md only — the ephemeral file deleted by the post-commit hook.

## Testing Decisions

Good tests for the plan-deletion detection verify external behavior only: given a specific set of staged file statuses, does the function return the expected commit message or null? Tests must not assert on internal implementation details (which git commands are called, how files are read).

The only module requiring tests is the plan-deletion detection logic in `git-commit-message`. All skill and prompt changes are configuration artifacts — they are the artifact, not something that wraps an artifact.

Prior art: existing tests for `commitWithHint` and `commitWithoutHint` in the `__tests__` directory next to the script demonstrate the pattern for testing commit strategy modules with mocked git state.

## Out of Scope

- Fixing commits already in main's history — this PRD only improves messages going forward.
- Enforcing a body on all non-mechanical commits — data shows 145/149 commits already have bodies; the prompts are working correctly.
- Handling duplicate subject lines across commits — determined to be caused by a stale COMMIT_HINT.md leaking across sessions, resolved by the upstream ralph fix.
- Mixed-concern commits not involving plan deletion — the existing "pick ONE most significant change" prompt rule is sufficient.
- Adding the `plan` type to any external linter or commit-msg hook.

## Further Notes

The `plan` type is not part of the Conventional Commits specification. It is a project-local extension. Both prompts must list it identically to avoid documentation inconsistency.

The prd skill's COMMIT_HINT step should instruct the model to derive the Goal from the Problem Statement section of the PRD.md it just wrote — this is the most concise, already-written summary of why the plan exists.
