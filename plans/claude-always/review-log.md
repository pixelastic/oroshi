## Issue 02 — Test infrastructure

### Missing `set -e` in hook
```zsh
#!/usr/bin/env zsh
# (no set -e)
local hookDir="${0:A:h}"
```
**Problem:** zsh-writer header.md requires `set -e` for shebang scripts.
**Reason skipped:** Guidance explicitly documents this exception — `set -e` was removed from the hook after unexpected exits in the decision matrix.

### Missing `bats_load_library 'helper'` in test file
```bash
setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash"
  # no bats_load_library 'helper', no bats_tmp_dir/bats_cleanup
```
**Problem:** zsh-writer testing.md requires the helper library pattern.
**Reason skipped:** Pre-existing; these hook tests don't use oroshi bats helpers and all 9 tests pass without them. Fixing would require adding the helper as a test-only dependency, out of scope.
