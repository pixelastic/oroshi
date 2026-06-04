## Problem Statement

When writing BATS test files, the agent regularly uses `run zsh` directly instead of the custom helpers (`bats_run_function`, `bats_run_script`) that provide proper mock injection, sandbox isolation, and ZSH autoload support. This forces repeated manual corrections in code reviews and skill updates, but without automated enforcement the same mistakes keep recurring.

There is currently no linter for `.bats` files. ZSH source files have `zshlint` (ShellCheck + custom rules), but test files are completely unchecked — neither for syntax correctness nor for adherence to project-specific BATS conventions.

## Solution

Introduce `bats-lint`: a linter for `.bats` test files that mirrors the architecture of `zshlint`. It combines a ShellCheck pass (for bash syntax correctness) with a custom rules engine (for project-specific BATS conventions). The first custom rule flags `run zsh` usage and directs the author to use `bats_run_function` instead.

`bats-lint` is integrated into the pre-commit pipeline (via lint-staged), into `git-file-lint` (which is refactored into a multi-type dispatcher), and into the skills that guide the agent when writing ZSH code and tests.

## User Stories

1. As a developer, I want `bats-lint` to run ShellCheck on `.bats` files with bash dialect, so that syntax errors are caught before commit.
2. As a developer, I want `bats-lint` to flag any use of `run zsh` in test files, so that I am directed to use the appropriate project helper instead.
3. As a developer, I want the violation message for `run zsh` to say "Use bats_run_function instead of run zsh", so that the correction is unambiguous.
4. As a developer, I want `bats-lint` output to be in the same JSON format as `zshlint`, so that tooling (editor integration, git-file-lint) can consume both uniformly.
5. As a developer, I want to run `bats-lint <filepath>` from the CLI, so that I can lint a single test file interactively.
6. As a developer, I want lint-staged to automatically run `bats-lint` on every staged `.bats` file at pre-commit time, so that violations are caught before they land in the repo.
7. As a developer, I want `git-file-lint` to run `bats-lint` on dirty `.bats` files alongside `zshlint` for dirty `.zsh` files, so that a single command lints all modified files regardless of type.
8. As a developer, I want `git-file-lint` output to be grouped by file type (ZSH section, then BATS section), so that violations are easy to scan.
9. As a developer, I want `git-file-lint` groups to be suppressed when a type has no violations, so that the output stays clean.
10. As a developer, I want the `zsh-writer` skill to instruct the agent to run `bats-lint` on the `.bats` test file after writing it, so that the agent self-corrects before asking for review.
11. As a developer, I want `CLAUDE.md` to document the `bats-lint <filepath>` command, so that the agent always knows how to lint a BATS file.
12. As a developer, I want each custom rule to be a standalone ZSH function with a unique code, so that I can add new rules in the future without modifying the runner.
13. As a developer, I want to disable a rule on a specific line with an inline comment (`# bats-lint-disable <code>`), so that intentional exceptions can be documented without silencing the whole file.
14. As a developer, I want the ShellCheck exclusion list to start minimal and grow over time as false positives are discovered, so that the linter is strict by default.
15. As a developer, I want `git-file-lint` to be structured so that adding a new file-type linter (e.g. JavaScript) requires only adding a new dispatch branch, so that the tool scales to future types without a rewrite.

## Implementation Decisions

### Architecture: mirror of zshlint

`bats-lint` has three executables:
- **Orchestrator** (`bats-lint`): receives a file path, calls `bats-lint-shellcheck` and `bats-lint-custom` in parallel, merges their JSON arrays, outputs the combined result.
- **ShellCheck wrapper** (`bats-lint-shellcheck`): runs `shellcheck --shell=bash` on the file, transforms output to the shared JSON format. Exclusion list starts minimal; false positives are suppressed incrementally.
- **Custom rules runner** (`bats-lint-custom`): discovers all rule functions in the `__rules/` directory, runs each against the file, merges violations into a JSON array.

### Rule format

Each rule is a standalone ZSH function (one file per rule) that:
1. Reads the target file
2. Outputs violations in a separator-delimited format (same as zshlint rules: `▮`-delimited fields: `line▮col▮code▮message`)
3. Is converted to JSON by the runner

Rules can be disabled per-line with `# bats-lint-disable <code>`.

### Rule: `noRunZsh`

Detects any occurrence of `run zsh` in a `.bats` file.
- **Code:** `noRunZsh`
- **Message:** "Use bats_run_function instead of run zsh"
- Intentionally simple: no attempt to distinguish script vs function invocation. False positives will be addressed as they arise by refining the rule or splitting it.

### JSON output format

Identical to zshlint:
```
[{ "file": "...", "line": N, "col": N, "code": "...", "message": "..." }]
```

### `scripts/yarn/lint-bats` wrapper

A thin wrapper (same pattern as `lint-zsh`) that:
1. Filters arguments to `.bats` files only
2. Calls `bats-lint` on each matching file
3. Exits non-zero if any violations are found

### `lintstaged.config.js` update

Add a new pattern:
- Key: `**/*.bats`
- Value: `['./scripts/yarn/lint-bats']`

This covers all `.bats` files in the repo regardless of location.

### `git-file-lint` refactor

The function is refactored from a ZSH-only linter into a multi-type dispatcher:
1. Get all dirty files from git
2. Partition files by type (ZSH via `is-zsh`, BATS via `.bats` extension)
3. For each type that has files, run the corresponding linter and collect output
4. Display results grouped by type with a header, only for types that have violations
5. Exit non-zero if any group has violations

Adding a new file type in the future requires adding one partition + one linter call.

### Skills updates

- **`zsh-writer/SKILL.md`**: In the lint step (Step 4), after running `zshlint` on the `.zsh` file, add an instruction to also run `bats-lint` on the corresponding `.bats` test file.
- **`CLAUDE.md`**: Add `Linting bats: Run bats-lint <filepath>` to the Commands section.

## Testing Decisions

Good tests verify external behavior only: given this input file content, does the linter output the expected violations (or no violations)? Tests must not assert on internal rule implementation details, file structure, or error message wording beyond what the contract specifies.

### Modules with tests

| Module | Test type | Prior art |
|--------|-----------|-----------|
| `rule-no-run-zsh` | Unit — one `.bats` per rule | `scripts/bin/zsh/zshlint/__rules/__tests__/rule-*.bats` |
| `bats-lint-custom` | Integration — fixture files with known violations | `scripts/bin/zsh/zshlint/__tests__/zshlint-custom.bats` |
| `bats-lint-shellcheck` | Integration — valid/invalid bash syntax | `scripts/bin/zsh/zshlint/__tests__/zshlint-shellcheck.bats` |
| `bats-lint` | Integration — orchestrator merges both outputs | `scripts/bin/zsh/zshlint/__tests__/zshlint.bats` |
| `git-file-lint` | Unit — new BATS dispatch branch | `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-lint.bats` |

### Test helpers

Rule unit tests reuse the existing `rules-helper` library (`run_rule`, `expect_rule_violation`) without modification. Rules are ZSH functions regardless of whether they target `.zsh` or `.bats` content.

### Modules without tests

- `scripts/yarn/lint-bats`: trivial wrapper, no behavioral logic
- `lintstaged.config.js`: config file, not behavioral code
- `zsh-writer/SKILL.md`, `CLAUDE.md`: documentation updates

## Out of Scope

- **NeoVim/ALE integration** for `.bats` files — can be added later once the linter is stable.
- **`run zsh` with script path** — the `noRunZsh` rule does not distinguish between `run zsh script.zsh` and `run zsh -c "autoload fn && fn"`. A `noRunZshScript` variant pointing to `bats_run_script` may be added post-merge.
- **JavaScript file type in `git-file-lint`** — the refactor enables it, but the JS dispatch branch is not added in this PRD.
- **Additional custom rules** — the framework supports them; new rules will be added in follow-up PRDs as pain points are identified.
- **Disabling bats-lint for an entire file** — only per-line disable comments are supported in this iteration.
- **`tdd/SKILL.md` update** — the skill does not explicitly mention `.bats` files, so no change is needed.
- **`ralph/SKILL.md` update** — Ralph already uses `git-file-lint` generically; it will benefit automatically from the `git-file-lint` refactor.
