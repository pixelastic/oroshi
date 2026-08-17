## Problem Statement

The allow-list and rewrite-list are global — one file shared by all repos. Some repos need extra commands allowed (or extra rewrites) without granting them everywhere.

## Solution

Per-repo `.claude/allow-list.json` and `.claude/rewrite-list.json` files that get appended/merged with the global lists. The hook wrapper detects them and passes multiple files to solkan.

## User Stories

1. As a developer, I want to add repo-specific allowed commands in `.claude/allow-list.json`, so that I can use project-specific tools without polluting the global allow-list.
2. As a developer, I want to add repo-specific rewrites in `.claude/rewrite-list.json`, so that dangerous commands in a specific project get rewritten without affecting other repos.
3. As a developer, I want local lists to be optional, so that repos without them behave exactly as before.
4. As a developer, I want allow-list and rewrite-list to be independent, so that I can have one without the other in a given repo.
5. As a developer, I want the global files renamed to `allow-list.json` and `rewrite-list.json`, so that naming is consistent between global and local files and matches the solkan flag names.
6. As a developer, I want local files committed to the repo, so that teammates benefit from the same project-specific lists.
7. As a developer running parallel Claude sessions in the same repo, I want no race conditions or file conflicts from the local list merge.

## Implementation Decisions

- **Merge strategy**: append-only. Local arrays concatenate with global arrays. Local rewrite objects merge with global objects (local wins on conflict). No override/subtract mechanism.
- **Repo root detection**: use `git-directory-root` helper (already allowlisted), not `git rev-parse --show-toplevel`.
- **Conditional passing**: the wrapper checks `[[ -f ]]` per file and only adds extra `--allow-list-file` / `--rewrite-list-file` flags when the local file exists. Each file is checked independently.
- **Logic encapsulation**: all local-file detection lives inside `preToolUse-Bash-solkan()`, not in the caller.
- **File locations**: `.claude/allow-list.json` and `.claude/rewrite-list.json` in the repo root.
- **Global rename**: `allowlist.json` → `allow-list.json`, `rewrite.json` → `rewrite-list.json` for naming consistency.
- **Solkan multi-file support**: handled in a separate sidequest (`solkan-multi-file`). This plan assumes solkan already accepts multiple `--allow-list-file` and `--rewrite-list-file` flags.

## Testing Decisions

- Tests use bats, following the existing `preToolUse-Bash-solkan.bats` pattern.
- Test the wrapper function with mock local files in a temp directory.
- Good tests verify external behavior: "command X is allowed when it's in the local allow-list but not the global one."
- Prior art: `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-solkan.bats`.
- The rename module is tested by running existing tests against the renamed files.

## Out of Scope

- Override/subtract mechanism (blocking globally-allowed commands per-repo).
- Solkan multi-file support (separate sidequest).
- UI/notification changes for local vs global allow decisions.
- Nested repo detection (monorepo sub-packages with their own `.claude/` directories).

## Further Notes

- The solkan sidequest (`solkan-multi-file`) must land before module 2 can be integration-tested. Module 1 (rename) has no dependency on solkan changes.
