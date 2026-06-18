## TLDR

Strip boilerplate `teardown()` blocks from ~120 `.bats` files identified by the `noBoilerplateTeardown` lint rule.

## What to build

Run `bats-lint` on all 157 `.bats` files to get the list of files with `noBoilerplateTeardown` violations. For each file, remove the boilerplate `teardown()` block — whether one-liner or multiline.

The one file with a non-trivial teardown (`tools/ai/rtk/__tests__/rtk.bats`) should NOT be touched — it has extra cleanup logic beyond `bats_cleanup`.

After migration, run the full test suite to confirm nothing is broken.

## Scaffolding Tests

- Running `bats-lint` on all `.bats` files reports zero `noBoilerplateTeardown` violations after migration.

## Acceptance criteria

- [ ] No `.bats` file contains a boilerplate `teardown() { bats_cleanup; }` block
- [ ] `rtk.bats` retains its custom teardown unchanged
- [ ] `bats-lint` reports zero `noBoilerplateTeardown` violations across all `.bats` files
- [ ] Full test suite passes
