## Problem Statement

`git-commit-message` produces poor commit messages when all staged changes are file renames with no content modifications. The diff is non-empty (rename headers) but content-free, so it bypasses the binary fallback and the LLM receives nothing useful. Additionally, both `commitWithHint` and `commitWithoutHint` duplicate identical diff-collection logic.

## Solution

Extract diff collection into a shared `getDiff` helper that uses Gilmore's `stagedFilesWithStatus()` (rename-aware) to classify staged files and build the appropriate diff string — including a rename-specific fallback block for 100%-similarity renames, analogous to the existing binary fallback.

## User Stories

1. As a developer who renamed files, I want git-commit-message to produce a message like "rename X to Y" instead of a confusing or empty message
2. As a developer who renamed files and edited content, I want the commit message to reflect both the rename and the content changes
3. As a developer who renamed files alongside binary additions, I want both renames and binaries listed in the fallback
4. As a developer, I want the same diff logic for hint and no-hint strategies so behavior is consistent
5. As a developer using git-commit-message with non-rename commits, I want existing behavior unchanged

## Implementation Decisions

- **Shared `getDiff` module** replaces the duplicate `getDiff()` methods in both strategies. Interface: `getDiff(excludedFiles: string[]) → Promise<string>`. Each strategy calls it with its own exclusion list.
- **Uses `stagedFilesWithStatus()`** from Gilmore (new method, assumed available) which returns `[{ name, status, from?, similarity? }]`. This replaces the current `stagedFiles()` + per-file diff approach.
- **Diff command uses `-M` flag** (`diff --cached -M -- <filepath>`) for rename detection.
- **Classification logic**: files with `status === 'renamed'` and `similarity === 100` are rename-only — no diff needed, routed to the rename fallback. All other files are diffed normally.
- **Rename fallback format**: `Files renamed:\n- old/path → new/path` — appended after content diffs, before binary fallback.
- **Binary fallback** unchanged: `Binary files added:\n- file` for files whose diff is empty.
- **Assembly order**: content diffs first, then rename block, then binary block. Empty blocks omitted.
- **Prompt templates** (`prompt-with-hint.md`, `prompt-without-hint.md`) are NOT modified — the rename block is self-explanatory for the LLM, same as the binary block.
- **Gilmore dependency** must be bumped to the version that includes `stagedFilesWithStatus()`, `parseStatus` rename support, and `stagedFiles` with `-M`.

## Testing Decisions

Tests should verify external behavior: given a set of staged files and their diffs, what string does `getDiff` return? Mock Gilmore's `stagedFilesWithStatus()` and `run()` — don't hit real git.

**Modules tested:**

- **`getDiff`** (new test file) — the deep module with all the logic:
  - Rename-only (100% similarity) → rename fallback block
  - Content changes only → raw diff
  - Binary-only → binary fallback block
  - Rename + content mixed → content diff + rename block
  - Rename + binary mixed → rename block + binary block
  - Rename + content + binary → all three
  - Excluded files are filtered out
  - Empty staging area → empty string

- **`commitWithHint`** (update existing tests) — add fixtures that include renames and binaries to verify they flow through `getDiff` correctly. Tests verify the strategy delegates properly.

- **`commitWithoutHint`** (update existing tests) — same: add rename and binary fixtures.

Prior art: existing tests in `__tests__/commitWithHint.js` and `__tests__/commitWithoutHint.js` use `vi.mock()` on Gilmore with `stagedFiles` and `run` mocks. The new tests follow the same pattern but mock `stagedFilesWithStatus` instead.

## Out of Scope

- Changes to Gilmore itself (handled in separate sidequest `gilmore-renames`)
- Prompt template modifications
- Rename detection for renames with < 100% similarity (these produce real diffs and work fine)
- Changes to `callApi`, `format`, or `getDeletedPlanName`
