## Problem Statement

The codebase has ~120 BATS test files accumulated over time. Many were written before current best practices were established (bats_run_zsh, bats_mock, setup() variable scoping, etc.). The bats-lint tool now exists but the test files themselves have never been systematically cleaned against it. As a result, agents reading the codebase as prior art encounter inconsistent patterns, and bats-lint violations mean the linter cannot be trusted to enforce quality autonomously.

## Solution

Do a full linting pass over all BATS files, domain by domain, in order of complexity. For each domain:

1. Run `bats-lint` on all files in the domain
2. Review each violation collaboratively — decide: fix the code, add a shellcheck/bats-lint-disable exception, or introduce a new custom bats-lint rule
3. When a new rule is needed, implement it (rule + test file + fixtures) in the same session
4. Confirm all files in the domain: 0 bats-lint violations + tests still pass
5. Move to the next domain

After all domains are processed, run a final global pass to catch violations introduced by rules added mid-campaign.

The result is a fully lint-clean test suite that serves as reliable prior art for agents, and a bats-lint ruleset mature enough to enforce quality autonomously going forward.

## User Stories

1. As an agent reading prior art, I want all BATS test files to follow consistent patterns, so that I can infer the correct way to write new tests without ambiguity.
2. As a developer, I want `bats-lint <file>` to return 0 violations on any test file, so that I can trust the linter as a meaningful quality gate.
3. As a developer, I want violations resolved at their root (fix, rule, or justified exception), so that lint-disables are not used to paper over real issues.
4. As a developer, I want new bats-lint rules discovered during the pass to have tests and fixtures, so that rules are as trustworthy as the code they lint.
5. As a developer, I want the helper library to be extended when a recurring pattern lacks a dedicated helper, so that test files stay concise and idiomatic.
6. As an agent, I want bats-lint to enforce modern patterns (bats_run_zsh, bats_mock, setup() scoping), so that I am guided toward correct patterns without needing to read all prior art first.
7. As a developer, I want the final global pass to catch cross-domain rule violations, so that early domains are not left with violations introduced by rules written later.

## Implementation Decisions

### Process

- **Decision unit**: one domain per work session (one issue)
- **Decision flow per violation**: fix code > add exception with justification > add new rule
- **New rule policy**: rule + test file + fixtures are written atomically in the same session — no rule ships without tests
- **No backtracking mid-pass**: when a new rule is added, previous domains are not re-cleaned immediately — the final global pass handles this
- **Helper additions**: new bats helpers are written inline when a recurring pattern is identified; no tests for helpers (coverage is implicit through test files that use them)

### Domain Order (complexity ascending)

| # | Domain | Files |
|---|--------|-------|
| 1 | bats-lint (core + rules) | 5 |
| 2 | bats utils | 1 |
| 3 | zsh-lint (core + rules) | 15 |
| 4 | json utils | 3 |
| 5 | theming + prompt | 3 |
| 6 | completion | 3 |
| 7 | misc utils | 4 |
| 8 | fzf | 4 |
| 9 | project | 6 |
| 10 | tools/ai (hooks, statusline, rtk) | 6 |
| 11 | ai functions | 2 |
| 12 | text utils (scripts/bin/text) | 8 |
| 13 | git utils (branch, directory, file, github, remote, tag) | 16 |
| 14 | ai scripts (ralph, review, prd) | 9 |
| 15 | git worktree | 14 |
| 16 | lua-lint + misc (audio, ebook, better-rm, etc.) | 11 |
| 17 | **Global cleanup pass** | all |

### bats-lint Rule Interface

Existing rules follow the pattern: output `file▮code▮severity▮line▮message` (Unicode separator U+25AE). New rules must follow the same interface and support inline disable via `# bats-lint-disable <RuleCode>`.

### Done Criteria per Domain

- `bats-lint <file>` exits 0 for every file in the domain
- `bats <file>` passes for every file in the domain
- Developer review sign-off

## Testing Decisions

- **What makes a good bats-lint rule test**: test the rule function directly using `run_rule` + `expect_rule_violation`; test both the violation case and the clean case; use minimal fixtures that isolate exactly the pattern being tested
- **No tests for bats helpers**: helper coverage is implicit — if tests using a helper pass, the helper works
- **New rule tests**: every new rule added during the pass gets a dedicated test file in `__rules/__tests__/` alongside a clean and a violating fixture
- **Prior art for rule tests**: `rule-no-run-zsh.bats` and `rule-no-inline-function.bats` are the canonical examples

## Out of Scope

- Fixing the zsh source files themselves (only test files are in scope)
- Adding new test coverage for untested functions
- Refactoring test logic beyond what is needed to satisfy bats-lint
- lua-lint rules (lua-lint domain is low priority; lua files are grouped with misc in issue #16)
- Any automation of the campaign (each domain is done interactively with developer review)

## Further Notes

- `bats-lint` currently runs shellcheck + two custom rules (`noRunZsh`, `noInlineFunction`). The ruleset is expected to grow during this campaign.
- The global shellcheck excludes already in place: SC2016 (intentional single-quoted vars in fixtures), SC2317 (unused mock functions). New global excludes may be added if a pattern is universally intentional across all BATS files.
- The memory entry `feedback_run_bats_lint_on_bats_files.md` notes that `git-file-lint` misses untracked files and the system bats-lint may lag the worktree — always run `bats-lint` explicitly from the worktree during the pass.
