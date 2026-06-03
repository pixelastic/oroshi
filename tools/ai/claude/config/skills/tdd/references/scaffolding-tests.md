# Scaffolding Tests

Apply the pivot question before writing any test:

> "If I rewrote the internals from scratch while keeping the same public API, would this test still pass?"

**NO** → scaffolding · **YES** → behavioral

## Definition

Verifies a structural transformation was applied correctly.
Is only needed to confirm the current issue being implemented is correctly implemented.
Does not survive an internal rewrite — it tests the shape of the implementation, not behavior.
Lives in `plans/<slug>/scaffold/<issue-filename>.bats` and is removed once the plan is archived.
