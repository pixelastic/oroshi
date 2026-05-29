## TLDR

Create the `plan-list-raw` helper — the single source of truth for listing plan directories.

## What to build

A new autoloaded function `plan-list-raw` in the `plan/` domain. It finds all direct subdirectories of `plans/` at the current git root (depth 1 only — no nested dirs like `issues/`) and prints one line per plan with two `▮`-separated fields: the absolute path and the basename.

When `plans/` does not exist, the function exits 0 with no output.

No arguments — the plans directory is always derived from `git-directory-root`.

Output format (one line per plan):
```
/abs/path/to/plans/my-feature▮my-feature
```

## Acceptance criteria

- [ ] `plan-list-raw` is autoloaded from the `plan/` domain
- [ ] Each output line is `fullAbsolutePath▮basename`
- [ ] Only direct subdirectories of `plans/` appear (depth 1)
- [ ] Nested subdirectories (e.g. `plans/my-feature/issues/`) do NOT appear
- [ ] Exits 0 with no output when `plans/` does not exist
- [ ] Full bats test suite covering all cases above
- [ ] `zshlint` passes on the new file
