# Test Types

Before each test, apply the pivot question:

> "If I rewrote the internals from scratch while keeping the same public API, would this test still pass?"

**YES** → permanent · **NO** → scaffolding

## Permanent

Verifies observable behavior through the public API.
Survives any internal rewrite
Lives in the project's test suite forever.

## Scaffolding

Verifies a structural transformation was applied correctly.
Deleted when the plan is archived.
Lives at `plans/<slug>/scaffold/issue-N.bats`
