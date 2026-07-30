## Issue 01 — commit-message-repo-arg
### Per-test mocking in repo path tests
```javascript
it.each([
  {
    title: 'passes repo path to Gilmore when provided',
    repoPath: '/tmp/other-repo',
    expected: ['/tmp/other-repo'],
  },
  {
    title: 'defaults to undefined when repo path is omitted',
    repoPath: undefined,
    expected: [undefined],
  },
])('$title', async ({ repoPath, expected }) => {
  Gilmore.mockReturnValue({
    status: vi.fn().mockReturnValue([]),
  });
  await getDeletedPlanName(repoPath);
  expect(Gilmore).toHaveBeenCalledWith(...expected);
});
```
**Problem:** Reviewer flagged mock setup inside each test body instead of shared `beforeEach`.
**Reason skipped:** The two `it.each` rows assert different call signatures (with arg vs undefined). A shared `beforeEach` would still need per-case call logic, so extracting adds no clarity.

## Issue 02 — commit-create-all-auto
### Missing guard comment on if block
```zsh
# First arg is repo path if it exists and doesn't start with -
if [[ $# -gt 0 && "$1" != -* ]]; then
  repoPath="$1"
  shift
fi
```
**Problem:** Reviewer flagged the `if` block as missing a guard comment.
**Reason skipped:** The comment on line 11 directly above the `if` already explains the guard.
