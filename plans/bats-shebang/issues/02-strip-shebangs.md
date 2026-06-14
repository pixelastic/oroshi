## TLDR

Remove `#!/usr/bin/env bats` from all 32 `.bats` files, strip `+x` from the 11 that have it, and delete the stale shebang test from `rule-no-top-level-var`.

## What to build

Three mechanical changes:

1. **Strip shebang line:** Remove line 1 from every `.bats` file whose first line is `#!/usr/bin/env bats`. 32 files in total (list via `grep -rl '#!/usr/bin/env bats' $OROSHI_ROOT --include='*.bats'`).

2. **Strip execute bit:** Remove `+x` from the 11 `.bats` files that currently have it (same set as above, filtered by `ls -la | grep '^-rwx'`).

3. **Remove stale test:** Delete the test case "no violation for shebang" from `rule-no-top-level-var.bats`. The `rule-no-top-level-var` rule itself is unchanged — its regex never matched shebangs anyway, making the test redundant.

## Scaffolding Tests

After all edits, running `bats-lint` on every `.bats` file in the repo must return 0 violations and exit 0.

## Acceptance criteria

- [ ] No `.bats` file contains `#!/usr/bin/env bats` on line 1
- [ ] No `.bats` file has the execute bit set
- [ ] "no violation for shebang" test removed from `rule-no-top-level-var.bats`
- [ ] `bats-lint $(grep -rl '.' $OROSHI_ROOT --include='*.bats')` exits 0
- [ ] `bats rule-no-top-level-var.bats` still passes
