## Issue 02 — ralph-single

### Spec: bats_run_function not used

```bats
bats_run_zsh "$CURRENT" "$PRD_DIR"
```

**Problem:** Issue spec says "Write `ralph-single.bats` using `bats_run_function` (not `bats_run_script`)".

**Reason skipped:** `bats_run_function` is marked `DEPRECATED` in `tools/term/bats/config/helper` ("use `bats_run_zsh` with the full path to the autoload function instead"). The codebase migrated all tests to `bats_run_zsh` (commits `1a641105`, `47aa3f8a`). The actual prior art file `preToolUse-Bash-rtk.bats` uses `bats_run_zsh`. The spec was written before the migration.
