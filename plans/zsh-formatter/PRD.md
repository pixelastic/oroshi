## Problem Statement

`zsh-fix` uses `shfmt` as its primary formatter, but shfmt does not support ZSH. It silently corrupts ZSH-specific syntax — inserting spaces into associative array subscripts (`ICONS[badge-separator]` → `ICONS[badge - separator]`), rejecting parameter expansion flags (`${(f)content}`), and breaking 12+ categories of valid ZSH constructs. The existing regex-based corruption detection only catches one pattern. There is no reliable ZSH formatter available today.

## Solution

Replace shfmt with beautysh as the sole formatter in `zsh-fix`. beautysh is a regex-based indentation formatter that handles indentation normalization and trailing whitespace removal without parsing expressions — so it cannot corrupt ZSH-specific syntax. Extend `zsh-fix` to accept multiple files for batch performance (one Python startup instead of N).

## User Stories

1. As a ZSH developer, I want `zsh-fix` to normalize indentation without corrupting associative array subscripts, so that my scripts work after formatting
2. As a ZSH developer, I want `zsh-fix` to normalize indentation without corrupting parameter expansion flags like `${(f)...}`, `${=var}`, `${~var}`, so that ZSH-specific syntax is preserved
3. As a ZSH developer, I want `zsh-fix` to remove trailing whitespace, so that diffs stay clean
4. As a ZSH developer, I want `zsh-fix --in-place file1 file2 file3` to format multiple files in a single invocation, so that lint-staged and zsh-lint batch calls are fast (~60ms total instead of 60ms × N)
5. As a ZSH developer, I want `zsh-fix file` (without --in-place) to output formatted content to stdout, so that I can preview changes before applying them
6. As a ZSH developer, I want `echo "code" | zsh-fix` to format stdin to stdout, so that I can use it in pipelines
7. As a ZSH developer, I want `zsh-fix file1 file2` (without --in-place) to error, so that the ambiguous "multiple files to stdout" case is explicitly rejected
8. As a ZSH developer, I want `zsh-lint --fix file1 file2` to format all files in one beautysh invocation, so that batch linting is fast
9. As a ZSH developer, I want a fixture-based test that proves formatting works and ZSH syntax is not corrupted, so that switching formatters in the future triggers a regression if they corrupt ZSH

## Implementation Decisions

### Module 1 — zsh-fix (rewrite)

- Remove shfmt entirely. beautysh is the sole formatter.
- `--in-place file1 file2...` passes all files directly to a single `beautysh --indent-size 2` call (no tmpdir needed — beautysh modifies in place natively).
- Single file without `--in-place`: copy to tmpdir, run beautysh on the copy, cat to stdout.
- stdin: write to tmpdir, run beautysh on the tmpfile, cat to stdout.
- Multiple files without `--in-place`: print error and exit 1.

### Module 2 — zsh-lint (patch)

- Replace the `for file; do zsh-fix --in-place "$file"` loop with a single `zsh-fix --in-place "${valid[@]}"` call.

### Module 3 — Fixtures

- `fixture-unformatted.txt` — ZSH code with bad indentation, trailing whitespace, and ZSH-specific syntax (associative arrays, parameter expansion flags, glob qualifiers). Uses `.txt` extension to prevent editors and lint-staged from auto-formatting it.
- `fixture-formatted.zsh` — expected output after beautysh formatting. ZSH-specific syntax must be byte-identical to the input.

### shfmt remains installed

- shfmt stays in the codebase for bash/sh formatting (NeoVim conform.nvim uses it for `bash` and `sh` filetypes).
- Only removed from `zsh-fix`.

## Testing Decisions

Good tests verify external behavior through the public interface. They use fixture files for formatting correctness and mock collaborators (not filesystem state) when testing interaction.

### Module 1 — zsh-fix

Prior art: existing `zsh-fix.bats` (5 tests). Test framework: bats with `bats_run_zsh`.

Tests to keep/adapt:
- File argument → formatted content to stdout, original unchanged
- `--in-place` → file modified in place, nothing to stdout
- stdin → formatted content to stdout

Tests to add:
- Meta-test: `fixture-unformatted.txt` → output matches `fixture-formatted.zsh` (covers indentation, trailing whitespace, ZSH syntax preservation)
- Multi-file `--in-place`: two files both get formatted
- Multi-file without `--in-place`: exits with error

Tests to remove:
- "shfmt failure: beautysh is called as fallback" (shfmt removed)
- "shfmt success: beautysh not called" (shfmt removed)

### Module 2 — zsh-lint

Prior art: existing `zsh-lint.bats` (12 tests).

Test to add:
- `--fix` with 2 mal-formatted files → both are corrected

## Out of Scope

- Removing shfmt from NeoVim config, Mason dependencies, or allowlist (still used for bash/sh)
- Expression-level formatting (operator spacing, case alignment, redirect spacing) — beautysh doesn't do this and that's accepted
- Blank line normalization — beautysh doesn't handle this
- Custom awk/sed formatter to replace beautysh — not needed given beautysh's acceptable performance
- Performance optimization beyond batching (zipapp, daemonization) — 60ms is acceptable
