## TLDR

Inject the `COMMIT_HINT` into the Claude prompt when present, so the generated commit message reflects Ralph's intent.

## What to build

Three coordinated changes:

1. **`prompt.md`**: add a `{{COMMIT_HINT}}` placeholder between Step 1 (Identify the change) and Step 2 (Write the subject line).

2. **`getCommitHint()` internal function** in the main script: calls `plan-directory` via subprocess (no arguments — deduces cwd automatically), reads `COMMIT_HINT` if the file exists. Returns the raw file content as a string, or `null` if `plan-directory` fails or the file is absent. Use `firost` for all file operations (exists checks, reads, absolute paths).

3. **Main script wiring**: after reading the prompt template, call `getCommitHint()`. Replace `{{COMMIT_HINT}}` with either:
   - An empty string if null.
   - A short instruction followed by the hint content if present — e.g. *"The following hint was written by the agent who implemented these changes. Treat it as the primary source for type, scope, and subject. Use the diff to verify and refine the body."* + newline + hint content.

## Behavioral Tests

**`getCommitHint`**

- returns `null` when `plan-directory` exits non-zero
- returns `null` when `plan-directory` succeeds but `COMMIT_HINT` does not exist
- returns file content when `plan-directory` succeeds and `COMMIT_HINT` exists

**main script**

- when `getCommitHint` returns `null`, the API is called with a system prompt that does not contain the hint instruction
- when `getCommitHint` returns a string, the API is called with a system prompt that contains the hint instruction and the hint content

## Acceptance criteria

- [ ] `prompt.md` has `{{COMMIT_HINT}}` placeholder positioned between Step 1 and Step 2
- [ ] `getCommitHint()` exists in the main script and returns `null` or file content
- [ ] `getCommitHint()` uses `firost` for file operations
- [ ] Main script replaces the placeholder correctly in both cases
- [ ] All behavioral tests pass
