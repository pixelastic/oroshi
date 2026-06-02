# The London School of TDD Mocking

- **Unit (fine-grained):**
Test a private method or helper directly when it contains complex logic.
`private` is an API-visibility decision, not a testability decision.
If the logic is complex enough to get wrong, it deserves its own test.

- **Integration (coarse-grained):**
Test a public function that calls private helpers by mocking those helpers.
This isolates the caller's branching logic from the helper's implementation.

**The rule:** mock your **immediate** collaborators, not their descendants.

## Example

```
isGitRepo()    — test directly (unit)
isWorktree()   — test directly (unit)
detectContext() calls both — test detectContext() by mocking isGitRepo and isWorktree
```
