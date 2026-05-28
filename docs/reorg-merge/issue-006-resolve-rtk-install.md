## PRD

[Merge main into reorg](PRD.md)

## What to do

Resolve the conflict in `tools/ai/rtk/install`.

## What each branch changed

**Main** removed the last 3 lines of the install script (the `rtk init` call):
```diff
-# Configure rtk
-rtk init --global --no-patch
```

**Reorg** (R094) renamed the file from `scripts/install/ai/rtk` to `tools/ai/rtk/install`. The 94% similarity means the content barely changed — likely just a path reference update.

## Resolution

Low risk. Take the file as reorg has it at `tools/ai/rtk/install`, then remove the `rtk init` lines that main deleted:

```bash
git show main:scripts/install/ai/rtk | tail -5   # verify what was deleted
# Remove the 3 lines manually, or:
git checkout --theirs tools/ai/rtk/install        # if git left conflict markers
# Then re-apply reorg's path updates if needed
```

The simplest approach: look at the conflict markers, keep the hunk without `rtk init --global --no-patch`.

## Acceptance criteria

- [ ] No `<<<<<<` markers
- [ ] No `rtk init --global --no-patch` line in the file
- [ ] File is at `tools/ai/rtk/install` (not the old path)

## Blocked by

issue-001
