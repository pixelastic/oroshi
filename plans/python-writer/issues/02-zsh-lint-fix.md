## TLDR

Add `--fix` flag to `zsh-lint`: auto-format via zshfix, then report remaining lint violations.

## What to build

Update `scripts/bin/zsh/zsh-lint/zsh-lint` to accept a `--fix` flag. When passed:
1. Run `zshfix` on the file (auto-format: indentation via shfmt/beautysh)
2. Run the normal lint check and output remaining violations (exit non-zero if any remain)

Without `--fix`, behavior is unchanged.

`zshfix` stays as the internal formatting implementation — `zsh-lint --fix` is the unified public interface, mirroring `python-lint --fix` and `yarn lint:fix`.

Add new bats test cases to the existing `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`.

## Behavioral Tests

**When `--fix` is passed and the file has fixable formatting:**
- `zshfix` is called on the file
- The lint check runs on the (now-formatted) file

**When `--fix` is passed and lint violations survive auto-format:**
- Violations are still reported
- Exit code is non-zero

**Without `--fix`:**
- `zshfix` is not called
- Existing behavior preserved

## Acceptance criteria

- [ ] `zsh-lint --fix <file>` calls zshfix then runs lint check
- [ ] `zsh-lint <file>` (no flag) behavior unchanged
- [ ] Violations surviving auto-format are still reported with `--fix`
- [ ] Exit non-zero when violations remain after fixing
- [ ] New bats cases added to existing `zsh-lint.bats` covering the above
