## Problem Statement

Running `vca` opens vim to write a commit message. Most of the time, the user generates a message with `vcm`, reviews it briefly, then accepts it. The round-trip through vim is a workflow interruption for the common case where the auto-generated message is good enough.

## Solution

A new `vcaa` alias that stages all files, auto-generates the commit message via `git-commit-message`, prints it to stdout, and passes it directly to `git commit`. No editor, no manual review — fire and forget.

## User Stories

1. As a developer, I want to stage and commit all changes with an auto-generated message in one command, so that I skip the vim round-trip when the generated message is good enough.
2. As a developer, I want to see the generated commit message printed before the commit happens, so that I can `vcz` if the message is wrong.
3. As a developer, I want `vcaa` to forward flags like `-n` (no-verify) to the underlying git commit, so that I keep the same flexibility as `vca`.
4. As a developer, I want `vcaa` to accept a repo path as first argument, so that I can auto-commit in a different repository without `cd`-ing there.
5. As a developer, I want `git-commit-message` to accept a repo path argument, so that other tools (including `vcaa`) can generate messages for arbitrary repositories.
6. As a developer, I want `vcaa` to abort cleanly if message generation fails, so that I don't end up with an empty or broken commit.

## Implementation Decisions

### Module 1: `git-commit-message` repo support

- The ZSH wrapper passes `$1` through to the JS script as a positional argument.
- The JS script passes the repo path to `Gilmore(repoPath)`. Gilmore already supports an optional root path — when provided, all git operations target that repo instead of cwd.
- All internal helpers (`getDiff`, `getDeletedPlanName`, `getCommitHint`) receive the Gilmore repo instance or repo path so they operate on the correct repository.

### Module 2: `git-commit-create-all-auto` autoload function

- New ZSH autoload function following the existing naming pattern.
- If `$1` exists and doesn't start with `-`, it's the repo path (shift it out). Otherwise, no repo.
- Calls `git-commit-message [repoPath]` and captures stdout into a variable.
- Echoes the message (plain `echo`, no decoration).
- Calls `git-commit-create-all [--repo repoPath] "$message" $@` — threading the repo as `--repo` (since `git-commit-create-all`'s first positional arg is already used for the commit message) and forwarding all remaining flags.
- `err_return` handles abort-on-failure naturally.

### Module 3: Alias + cleanup

- `vcaa='git-commit-create-all-auto'` in the commit aliases file.
- Remove the TODO entry for "vcaa auto-fill the commit message".

### Repo argument convention

Each git helper function accepts a repo path to target a specific repository:
- If the function's first positional argument slot is free, repo goes as first positional arg (e.g., `git-commit-message /path`).
- If the first positional slot is already used, repo is passed via `--repo` flag (e.g., `git-commit-create-all --repo /path "message"`).

## Testing Decisions

Good tests for this feature verify external behavior through the public interface — message generation targeting the correct repo, and argument forwarding — not internal wiring.

### Module 1: JS tests for repo threading

- Verify that `getDiff`, `getDeletedPlanName`, and `getCommitHint` pass the repo path to `Gilmore()`.
- Prior art: existing vitest mocks in `scripts/bin/git/commit/git-commit-message/__tests__/getDiff.js` — same pattern of mocking `Gilmore` and asserting call args.

### Module 2: Bats test for `git-commit-create-all-auto`

- Mock `git-commit-message` (returns a canned message) and `git-commit-create-all` (records args).
- Test 1: verify the canned message is passed as commit message to `git-commit-create-all`.
- Test 2: verify extra flags (e.g., `-n`) are forwarded to `git-commit-create-all`.
- Prior art: `tools/term/zsh/config/functions/autoload/git/commit/__tests__/git-commit-create-all.bats`.

## Out of Scope

- Dry-run or confirmation prompt for `vcaa` — the whole point is fire-and-forget.
- Interactive editing of the generated message — that's what `vca` + `vcm` is for.
- Changing the commit message generation logic itself.
