# Behavioral Tests

Apply the pivot question before writing any test:

> "If I rewrote the internals from scratch while keeping the same public API, would this test still pass?"

**YES** → behavioral · **NO** → scaffolding

**Exceptions**:
- Global install scripts are scaffolding
- Pre-commit hooks (`lintstaged.config.js`) are scaffolding

## Definition

Verifies observable behavior, not implementation details.
Survives any internal rewrite.
Lives in `__tests__/` forever.

## Grouping

One test should cover one behavior scenario.
One test can cover multiple acceptance criteria as long they describe the same
behavior.
Edge-cases can have their own dedicated tests.
Error handling can have their own dedicated tests.

## Mocking (London School)

**Rule:** mock your **immediate** collaborators, not their descendants.

- **Unit (fine-grained):**
It's ok to test a private method or helper directly when it contains complex logic.
`private` is an API-visibility decision, not a testability decision.

- **Integration (coarse-grained):**
Test a public function that calls private helpers by mocking those helpers.
This isolates the caller's branching logic from the helper's implementation.

Example:
```
isGitRepo()    — test directly (unit)
isWorktree()   — test directly (unit)
detectContext() calls both — test detectContext() by mocking isGitRepo and isWorktree
```
