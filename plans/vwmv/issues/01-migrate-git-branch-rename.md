## TLDR

Move `git-branch-rename` from `scripts/bin/` to the autoloaded functions directory and add BATS tests.

## What to build

`git-branch-rename` currently lives as a standalone shebang script in
`scripts/bin/git/branch/`. It should be an autoloaded function like all other
`git-branch-*` helpers.

- Remove the bin script.
- Create the autoloaded function under `git/branch/` in the autoload tree,
  keeping the same interface and same behavior (`git branch --move`).
- Add a BATS test file in the adjacent `__tests__/` directory.

The interface stays identical:
- `git-branch-rename <new>` — rename the current branch to `<new>`
- `git-branch-rename <old> <new>` — rename branch `<old>` to `<new>`

## Behavioral Tests

**1-argument form**
- Renames the current branch to the given name.

**2-argument form**
- Renames the named branch to the new name.

**No arguments**
- Fails with a non-zero exit code.

## Acceptance criteria

- [ ] Bin script at `scripts/bin/git/branch/git-branch-rename` deleted
- [ ] Autoloaded function created at `git/branch/git-branch-rename` in the autoload tree
- [ ] Function uses `setopt local_options err_return`
- [ ] BATS test file created in the adjacent `__tests__/` directory
- [ ] All 3 behavioral test cases covered
- [ ] `zsh-lint` passes on the new function
- [ ] `bats-lint` passes on the test file
