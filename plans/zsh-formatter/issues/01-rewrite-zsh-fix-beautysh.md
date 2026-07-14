## TLDR

Replace shfmt with beautysh in zsh-fix for single-file formatting, add fixture-based regression test.

## What to build

Rewrite `scripts/bin/zsh/zsh-fix/zsh-fix` to use beautysh as the sole formatter. Remove all shfmt logic and the fallback mechanism.

Three modes remain unchanged in interface:
- `zsh-fix file` — copy to tmpdir, run `beautysh --indent-size 2` on copy, cat to stdout
- `zsh-fix --in-place file` — run `beautysh --indent-size 2` directly on the file
- `stdin | zsh-fix` — write stdin to tmpdir, run beautysh on tmpfile, cat to stdout

Create two fixture files in `scripts/bin/zsh/zsh-fix/__tests__/`:
- `fixture-unformatted.txt` — ZSH code with bad indentation, trailing whitespace, plus ZSH-specific syntax that must NOT be altered (associative array subscripts with dashes/colons, parameter expansion flags like `${(f)...}`, `${=var}`, `${~var}`)
- `fixture-formatted.zsh` — expected output after beautysh

The `.txt` extension on the unformatted fixture prevents editors and lint-staged from auto-formatting it.

Rewrite `scripts/bin/zsh/zsh-fix/__tests__/zsh-fix.bats`:
- Remove the 2 shfmt-related tests
- Keep/adapt the 3 interface tests (file→stdout, --in-place, stdin)
- Add the fixture meta-test

## Behavioral Tests

**Single file to stdout**
- file argument: formatted content to stdout, original file unchanged

**In-place single file**
- --in-place: file modified in place, nothing to stdout

**Stdin to stdout**
- stdin: formatted content to stdout

**Formatting correctness (meta-test)**
- fixture-unformatted.txt processed through zsh-fix produces output matching fixture-formatted.zsh

## Acceptance criteria

- [ ] shfmt is no longer called anywhere in zsh-fix
- [ ] beautysh is the sole formatter
- [ ] File→stdout mode works (original unchanged)
- [ ] --in-place mode works
- [ ] stdin mode works
- [ ] fixture-unformatted.txt contains bad indentation, trailing whitespace, and ZSH-specific syntax
- [ ] fixture-formatted.zsh contains the expected beautysh output
- [ ] Meta-test passes: unformatted fixture → matches formatted fixture
- [ ] ZSH-specific syntax (associative arrays, expansion flags) is byte-identical before and after formatting
- [ ] All tests pass: `bats scripts/bin/zsh/zsh-fix/__tests__/zsh-fix.bats`
