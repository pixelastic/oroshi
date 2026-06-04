## Problem Statement

When Ralph finishes implementing an issue, it has full context: the goal, what was done, why, and which changes matter. But the commit message script only sees the staged diff — it gives too much weight to files in `plans/` and loses all the intent behind the real code changes. The result is commit messages that mention artefacts of the Ralph workflow (closed issues, progress files) instead of describing the actual change.

## Solution

Ralph writes a `COMMIT_HINT` file in its plan directory after completing an issue. The file is a free-form baton-pass note: goal, what was done, key changes, suggested type/scope. When the user manually stages files and commits, the commit message script detects the hint, injects it as high-priority context into the Claude prompt (via a placeholder), and generates a message that reflects both the intent (from the hint) and the actual staged content (from the diff). A post-commit hook deletes the hint after a successful commit so it is never reused.

## User Stories

1. As a user committing after a Ralph session, I want the commit message script to know what the issue was about, so that the generated message reflects intent rather than just diff noise.
2. As a user who stages only a subset of Ralph's changes, I want the script to reconcile the hint with the actual diff, so that the message describes what is actually being committed.
3. As a user making a manual commit unrelated to Ralph, I want the script to behave exactly as before when no hint is present, so that my workflow is not disrupted.
4. As a user who aborts a commit (e.g. quits NeoVim without saving), I want the hint to survive for the next commit attempt, so that I don't lose the context Ralph wrote.
5. As a user who successfully commits, I want the hint to be automatically deleted after the commit, so that it never pollutes a future unrelated commit.
6. As a user, I want the hint file to never appear in `git status` or `git diff`, so that it does not create noise in the working tree.
7. As Ralph (the agent), I want a clear, structured step in the DOCUMENT phase to write the hint, so that I always produce it consistently at the end of an issue.
8. As Ralph, I want the hint format to be free prose (not a strict schema), so that I can convey nuance without fitting into rigid fields.

## Implementation Decisions

- The hint file is named `COMMIT_HINT` and lives inside the plan directory for the current worktree (resolved via the `plan-directory` helper). This scopes it to the relevant worktree and issue, and avoids the `.git/` directory (which is a file, not a directory, in git worktrees).

- `plans/*/COMMIT_HINT` is added to `.gitignore` so the file is never tracked.

- `git-commit-message.js` gains an internal function `getCommitHint(cwd)`. It shells out to `plan-directory` to resolve the path, then reads `COMMIT_HINT` if it exists. Returns the raw file content as a string, or `null` if no hint is found (plan-directory fails, or file is absent). This function lives in the main script file, not a separate module.

- `prompt.md` contains a `{{COMMIT_HINT}}` placeholder positioned after Step 1 (Identify the change) and before Step 2 (Write the subject line). This ensures the hint is read early, before the subject is drafted.

- The main script calls `getCommitHint`, then replaces `{{COMMIT_HINT}}` in the prompt template:
  - If null: replaced with an empty string.
  - If present: replaced with a short instruction followed by the hint content — e.g. `"The following hint was written by the agent who implemented these changes. Treat it as the primary source for type, scope, and subject. Use the diff to verify and refine the body.\n\n<hint content>"`.

- The Ralph skill DOCUMENT step gains a new sub-step (after updating `state.json` and `GUIDANCE.md`): write `COMMIT_HINT` in the plan directory. The hint is free prose covering: what the issue aimed to do, what was actually done, the most important file-level changes, and a suggested `type(scope)`.

- A new post-commit hook (zsh) calls `plan-directory`. If a `COMMIT_HINT` exists at that path, it deletes it. If `plan-directory` fails or the file is absent, it exits silently. The hook runs only after a successful commit, so aborted or hook-failed commits leave the hint intact.

## Testing Decisions

Good tests verify observable external behavior — return values, side effects, API call arguments — not internal implementation details.

**`getCommitHint`** — unit tests (vitest), in the existing `__tests__/git-commit-message.js` file:
- Returns `null` when `plan-directory` exits non-zero (no plan in worktree).
- Returns `null` when `plan-directory` succeeds but `COMMIT_HINT` does not exist.
- Returns the file content when `plan-directory` succeeds and `COMMIT_HINT` exists.
- The subprocess call and filesystem read are stubbed.

**`git-commit-message` main flow** — integration tests (vitest), extending the existing test suite:
- When `getCommitHint` returns `null`: the API is called with a system prompt that does not contain the hint instruction.
- When `getCommitHint` returns a hint string: the API is called with a system prompt that contains the hint instruction and the hint content.
- `getCommitHint` is mocked; the fetch call is also mocked.

Prior art: existing `__tests__/git-commit-message.js` already mocks Gilmore and fetch — same pattern applies.

**`post-commit` hook** — bats tests:
- When no plan directory exists: script exits 0 and no file operations occur.
- When plan directory exists but no `COMMIT_HINT`: script exits 0 silently.
- When `COMMIT_HINT` exists: script deletes the file and exits 0.
- `plan-directory` is stubbed via `bats_mock`.

## Out of Scope

- Writing the commit message automatically without user action (Ralph never commits).
- Supporting multiple simultaneous hints (one hint per worktree at a time).
- Validating or linting the hint content written by Ralph.
- Surfacing the hint content to the user in the terminal before or after commit generation.
- Any changes to `format.js` or the wrapping logic.
