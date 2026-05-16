# PRD — review-diff + review skill overhaul

## Problem Statement

The `review` skill has two bugs and one structural problem:

1. **Untracked files are invisible** — `git diff HEAD` only covers tracked changes; new files (`??` in `git status`) are silently omitted from the review.
2. **Output is not token-optimized** — git commands run raw, not through `rtk`.
3. **Diff logic is untestable** — the git commands are inlined in the skill prompt, making them impossible to test or reuse.

The existing `review` shell script (`scripts/bin/ai/review`) is also limited: it only handles a single commit and passes it inline to Claude, giving Claude no way to chunk or search a large diff.

## Solution

Three changes:

**1. New `review-diff` script** — a standalone, testable script that generates full diff context for any git scope (working tree, branch, commit, or range). All output goes through `rtk`.

**2. Updated `SKILL.md`** — step 1 gains two entry points. If a pre-generated diff file is passed, Claude reads it with the Read tool. Otherwise, Claude interprets the user's natural language intent, translates it to `review-diff` args, and calls the script.

**3. Updated `review` shell script** — instead of passing a git ref inline to Claude, it runs `review-diff`, saves output to a named temp file (`/tmp/review-diff-<uuid>.md`), then calls Claude with that filepath. Claude reads it with the Read tool, enabling chunking and search on large diffs.

## User Stories

1. As Claude, when the review skill is invoked with no argument, I see all working-tree changes including untracked files, so that nothing is silently omitted.
2. As Claude, when the review skill is invoked with the name of my current branch, I see everything this branch has done since it forked from its parent, so that I can review my own work before merging.
3. As Claude, when the review skill is invoked with the name of a different branch, I see everything that branch would bring in that my current branch doesn't have, so that I can review incoming changes.
4. As Claude, when the review skill is invoked with a single commit SHA, I see only that commit's changes.
5. As Claude, when the review skill is invoked with two refs, I see the diff and log between them.
6. As Claude, when the review skill receives a `review-diff-<uuid>.md` filepath, I read it directly with the Read tool instead of re-running git commands, so that I can chunk or search large diffs.
7. As Claude, I receive all diff output through `rtk` so that token usage is minimised.
8. As Tim, running `review <args>` from the terminal pre-generates the diff and hands it to Claude as a file, so that large diffs don't bloat the session context.
9. As Tim, I can call `review-diff` directly from the terminal to inspect what the review skill will receive.
10. As Tim, I can invoke the review skill interactively in a Claude session using natural language (e.g. "review everything since the start of this branch") and Claude will translate it to the right `review-diff` call.
11. As Tim, I can run the bats test suite for `review-diff` to verify all cases pass.

## Implementation Decisions

### review-diff script

- **Location**: `scripts/bin/ai/review-diff` — alongside the existing `scripts/bin/ai/review`, in PATH.
- **Accepts 0, 1, or 2 positional args** — no flags.
- **Branch detection**: use `git-branch-exists` (existing zsh helper). Exit 0 → branch; non-zero → treat as commit SHA.
- **Branch diff direction**:
  - *Self-review* (arg == current branch): use `git-branch-parent` to find the base, diff from there to HEAD. Shows what this branch has done since forking.
  - *External review* (arg != current branch): diff from HEAD to the passed branch. Shows what that branch would bring in.
- **Two-dot for range**: direct diff between the two tip commits — no merge-base resolution, since the user explicitly named both bounds.
- **Untracked files** (0-arg only): included as new-file diffs; they do not appear in `git diff HEAD`.
- **rtk scope**: all output-producing git calls go through `rtk`. Branch detection, repo checks, and file enumeration do not.
- **Output**: raw concatenation — no section headers. Each case outputs: commit log (where applicable) + stat + full diff.

### SKILL.md update

- **Step 1 — filepath path**: if the argument matches the `review-diff-<uuid>.md` pattern, read the file directly with the Read tool. Do not call `review-diff`.
- **Step 1 — natural language path**: interpret the user's intent and translate to `review-diff` args. Examples: "review this branch" → `review-diff <current-branch>`; "review since main" → `review-diff main`; "review commit abc123" → `review-diff abc123`. Then call `review-diff` and use its stdout as diff context.
- All other steps (spec identification, standards sources, sub-agents) are unchanged.

### review shell script update

- Accepts 0, 1, or 2 args (same signature as `review-diff`).
- Runs `review-diff <args>`, saves stdout to `/tmp/review-diff-<uuid>.md`.
- Calls `claude-print "/review /tmp/review-diff-<uuid>.md"`.
- The named file pattern makes it unambiguous for the skill to detect and read directly.

## Testing Decisions

Tests cover `review-diff` only — it is the only module with pure input/output behaviour testable in isolation. The SKILL.md and shell script changes are verified by reading them.

Tests use bats with a temp git repo per test via `bats_tmp()`. Each test sets up the minimal state needed and asserts on stdout content.

- **Test location**: `scripts/bin/__tests__/review-diff.bats` — in the global test dir so the pre-commit hook picks it up.

Test cases:

- **0-arg, clean tree**: exits 0, empty output.
- **0-arg, modified tracked file**: output contains the diff hunk.
- **0-arg, untracked file**: output contains a new-file diff for the untracked file.
- **0-arg, staged file**: output contains the staged hunk.
- **1-arg branch, self-review**: on feature branch, pass feature — output contains the feature commit and a `diff --git` line.
- **1-arg branch, external review**: on main, pass feature — output contains the feature commit and a `diff --git` line; main-only commits are absent.
- **1-arg commit SHA**: output contains the commit message and a `diff --git` line.
- **2-arg range**: output contains commits and a `diff --git` line scoped to the range.

Prior art: `git-worktree-list.bats` — same setup/teardown pattern.

## Out of Scope

- Remote-only branch refs (e.g. `origin/main` as a single arg — treated as a commit SHA).
- Staged-only or unstaged-only filtering.
- Colourised output.
- Changes to the Standards or Spec sub-agent prompts in `SKILL.md`.
- Changes to `scripts/bin/__tests__/helper.bash`.
