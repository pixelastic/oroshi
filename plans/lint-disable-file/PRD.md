## Problem Statement

`zsh-lint` and `bats-lint` support line-level rule suppression via `# <prefix> disable=ruleName` placed above the offending line. There is no file-level mechanism to suppress a rule across an entire file.

This blocks generated files like `dist/projects.zsh`, which contain lines that legitimately exceed the `commandTooLong` limit (e.g. long associative array key-value assignments that cannot be split). These lines are not authored by a developer — they are emitted by build scripts — so a line-level disable comment would need to be re-emitted on every rebuild, and placed above each individual violation.

## Solution

Add a `# zsh-lint disable-file=ruleName1,ruleName2` comment syntax that suppresses one or more rules for the entire file when the comment appears anywhere in the file (conventionally at the top).

Update the build scripts that generate `dist/*.zsh` files to emit this comment as the first line of their output, so generated files are permanently exempt from `commandTooLong` without requiring per-line annotations.

## User Stories

1. As a developer, I want to suppress a lint rule for an entire file with a single comment, so that I don't need to annotate every individual violation.
2. As a developer, I want the file-level disable comment to work with a comma-separated list of rule names, so that I can suppress multiple rules with one comment.
3. As a developer, I want the file-level disable comment to work anywhere in the file, so that I have flexibility in where I place it.
4. As a developer, I want to conventionally place the file-level disable comment at the top of the file, so that readers immediately know the file has suppressed rules.
5. As a developer, I want the file-level disable to coexist with line-level disables, so that I can mix both mechanisms in the same file.
6. As a developer, I want `zsh-lint` to respect `# zsh-lint disable-file=` comments, so that zsh files can suppress rules file-wide.
7. As a developer, I want `bats-lint` to respect `# bats-lint disable-file=` comments, so that bats files can suppress rules file-wide.
8. As a developer, I want generated `dist/projects.zsh` to not emit `commandTooLong` violations, so that the lint pipeline passes without manual intervention after a rebuild.
9. As a developer, I want generated `dist/colors.zsh` to not emit `commandTooLong` violations, so that future additions to the colors table don't unexpectedly break lint.
10. As a developer, I want generated `dist/filetypes.zsh` to not emit `commandTooLong` violations, so that future additions to the filetypes table don't unexpectedly break lint.
11. As a developer, I want `disable-file` to only suppress the rules explicitly listed, so that unlisted rules still fire normally.
12. As a developer, I want line-level disable to continue working independently of file-level disable, so that existing annotations remain valid.

## Implementation Decisions

- **Shared implementation in `lint-custom-run`:** The disable-file logic is added to the shared orchestration function used by both `zsh-lint-custom` and `bats-lint-custom`. The `--disable-prefix` flag already parameterizes the comment prefix (`zsh-lint` vs `bats-lint`), so no additional interface changes are needed.

- **Scan strategy:** When a file's content is first loaded into the content cache (already done lazily per violation), also scan all lines of that file for `# <prefix> disable-file=<codes>` comments. Collect all matched rule codes into a per-file disabled-rules map. This piggybacks on the existing cache read, avoiding a second file read.

- **Filter order:** The file-level check runs before the line-level check. If a violation's rule code appears in the file's disabled-rules map, it is skipped immediately. The line-level check only runs for violations that survive the file-level filter.

- **Multiple `disable-file` comments:** If the same file contains multiple `disable-file=` comments, all matched codes from all comments are collected and merged. This allows splitting long disable lists across multiple comments if desired.

- **Syntax mirrors line-level:** `# zsh-lint disable-file=ruleName1,ruleName2` — same prefix, same comma-separated format, different keyword (`disable-file` vs `disable`).

- **Build scripts emit the comment as the first output line:** Each build script's `generateDistZsh()` function prepends `# zsh-lint disable-file=commandTooLong` before the `typeset -gA` declaration. All three build scripts are updated defensively, even if only `projects.zsh` currently has violations.

## Testing Decisions

Good tests assert external behavior — what the linter outputs given a particular input — not how the filter loop is structured internally. Tests should use real files (written to a tmp directory) and drive the full `zsh-lint-custom` / `bats-lint-custom` pipeline, not `lint-custom-run` directly.

**Modules with tests:**

- `zsh-lint-custom` — tested via `zsh-lint-custom.bats`. New tests follow the pattern of the existing `disable=` tests: write a file to `$BATS_TMP_DIR`, run `zsh-lint-custom`, assert on exit code and output. Use `noGroupedLocals` as the triggered rule (same as existing disable tests).
  - Test: file with `disable-file=noGroupedLocals` at top suppresses all violations of that rule throughout the file
  - Test: `disable-file=X` does not suppress a different rule `Y` that also fires in the same file

- `bats-lint-custom` — tested via `bats-lint-custom.bats`. One new test following the pattern of the existing `bats-lint disable=` tests. Use `noRunZsh` as the triggered rule.
  - Test: file with `# bats-lint disable-file=noRunZsh` suppresses all `noRunZsh` violations

**Build scripts:** No tests. The generated `dist/*.zsh` files are the artifact; their correctness is validated by running the build and inspecting output. The disable comment is a one-line prepend with no logic to test.

## Out of Scope

- Enforcing that the `disable-file` comment must appear at the top of the file (placement is conventional, not enforced).
- File-level disable for third-party linters (e.g. `zsh -n`, `shellcheck`) — only custom rules via `lint-custom-run` are in scope.
- A mechanism to disable all rules for a file (wildcard `disable-file=*`) — explicit rule names are required.
- Changes to the `zsh-lint` or `bats-lint` orchestrator scripts themselves — the fix is entirely within `lint-custom-run`.
- Updating `dist/*.zsh` files in the repository — they are regenerated by running the build scripts.

## Further Notes

The three build scripts (`projects-build`, `colors-build`, `filetypes-build`) all generate `dist/*.zsh` files as build artifacts. Only `dist/projects.zsh` currently triggers `commandTooLong` (one line at 110 chars). The other two are updated preemptively: generated files cannot be manually edited and should be unconditionally exempt from this rule regardless of future data growth.
