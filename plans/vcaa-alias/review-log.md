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
