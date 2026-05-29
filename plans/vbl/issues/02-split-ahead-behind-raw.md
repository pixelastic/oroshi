## TLDR

Replace the combined `%(upstream:track)` field in `git-branch-list-raw` with separate `%(upstream:ahead)` and `%(upstream:behind)` fields, and update all consumers.

## What to build

Change `git-branch-list-raw` to emit 8 `▮`-delimited fields per line:

```
branch▮hash▮remoteName▮remoteBranchRef▮ahead▮behind▮date▮message
```

Field 5 becomes a numeric ahead count, field 6 a numeric behind count (both consistent with the order used in `git-worktree-list-raw`). The old combined track string is removed.

Update the two consumers:
- `complete-git-branches-local`: message field moves from `splitLine[7]` to `splitLine[8]`
- `git-branch-list`: ahead and behind are now separate fields; update parsing indices accordingly (fields 5 and 6 for ahead/behind, 7 for date, 8 for message)

Update the BATS tests from issue 01 to assert on the new 8-field format: field 5 is a numeric string, field 6 is a numeric string, no combined track string present.

## Acceptance criteria

- [ ] `git-branch-list-raw` emits 8 `▮`-delimited fields per line
- [ ] Field 5 is a numeric ahead count (0 or positive integer)
- [ ] Field 6 is a numeric behind count (0 or positive integer)
- [ ] No `[ahead N]` / `[behind N]` combined string appears in output
- [ ] `complete-git-branches-local` still returns `branch:message` correctly
- [ ] `vbl` renders without errors and column layout is intact
- [ ] BATS tests from issue 01 updated and passing on new format
