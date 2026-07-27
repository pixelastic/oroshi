## Issue 01 — Extract getDiff
### Missing __tests__/getDiff.js
```javascript
export async function getDiff(excludedFiles) {
```
**Problem:** New module has no dedicated test file
**Reason skipped:** Existing behavioral tests in commitWithHint/commitWithoutHint cover getDiff indirectly; dedicated tests are future scope

### No __ export for collaborator mocking
```javascript
const repo = Gilmore();
```
**Problem:** Gilmore() called inline instead of via __ object
**Reason skipped:** vi.mock('gilmore') at module boundary works across imports; __ pattern not needed until getDiff gets its own test file

### stagedFilesWithStatus() not used
```javascript
const stagedFiles = await repo.stagedFiles();
```
**Problem:** Spec says to use stagedFilesWithStatus()
**Reason skipped:** Switching breaks existing tests (AC #4); belongs to issue 02 where rename handling is added

### -M flag not passed to diff
```javascript
return repo.run(`diff --cached -- ${filepath}`);
```
**Problem:** Spec says diff --cached -M
**Reason skipped:** Existing tests assert exact command string; -M belongs to issue 02

## Issue 02 — rename fallback
### Return-early pattern vs accumulator
```javascript
const blocks = [];
if (contentDiff) { blocks.push(contentDiff); }
if (renames.length > 0) { ... }
if (binaries.length > 0) { ... }
return blocks.join('\n\n');
```
**Problem:** CLAUDE.md requires "return early" pattern; function uses sequential if-push instead
**Reason skipped:** Accumulator pattern — each block is additive and independent; return-early doesn't apply to assembly logic
