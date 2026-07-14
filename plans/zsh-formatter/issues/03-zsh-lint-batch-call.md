## TLDR

Change zsh-lint --fix to pass all files to a single zsh-fix call instead of looping.

## What to build

In `scripts/bin/zsh/zsh-lint/zsh-lint`, replace the per-file loop:
```zsh
for file in "${valid[@]}"; do
  zsh-fix --in-place "$file"
done
```
with a single batch call:
```zsh
zsh-fix --in-place "${valid[@]}"
```

Add a test to `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats` verifying that `--fix` with multiple mal-formatted files corrects all of them.

## Behavioral Tests

**Batch fix**
- --fix with two mal-formatted files: both files are corrected after the command

## Acceptance criteria

- [ ] zsh-lint --fix passes all valid files to a single zsh-fix invocation
- [ ] Test verifies two mal-formatted files are both corrected
- [ ] All tests pass: `bats scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`
