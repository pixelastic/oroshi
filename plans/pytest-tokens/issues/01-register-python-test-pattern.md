## TLDR

Register `^python-test\b` in `rtk-can-rewrite` so the preToolUse-Bash hook rewrites direct `python-test` calls to `rtk python-test`.

## What to build

Extend `rtk-can-rewrite` with a `^python-test\b` pattern, following the same approach as the existing `^bats\b` and `^yarn run test\b` patterns. After this change, the hook will recognize `python-test` as an RTK-rewritable command and route it through RTK.

Add two unit tests to `rtk-can-rewrite.bats` covering the new pattern. Prior art: existing tests for `bats` and `yarn run test` in the same file.

## Behavioral Tests

**Recognized commands**
- `rtk-can-rewrite "python-test foo.py"` exits 0
- `rtk-can-rewrite "python-test ./path/to/test_file.py"` exits 0

**Not recognized (no false positives)**
- `rtk-can-rewrite "python-test-something"` exits 1
- `rtk-can-rewrite "python foo.py"` exits 1

## Acceptance criteria

- [ ] `rtk-can-rewrite "python-test foo.py"` exits 0
- [ ] `rtk-can-rewrite "python-test-something"` exits 1 (no prefix false positive)
- [ ] All existing `rtk-can-rewrite` tests still pass
- [ ] `zsh-lint` passes on `rtk-can-rewrite`
