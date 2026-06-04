## Problem Statement

Lint scripts in the oroshi repo follow an inconsistent naming convention. All linters use the `{lang}-lint` pattern (e.g. `json-lint`, `css-lint`, `lua-lint-custom`) except the zsh scripts, which concatenate without a dash: `zshlint`, `zshlint-shellcheck`, `zshlint-custom`. This inconsistency propagates into internal function names (`zshlintRule_*`), the inline suppression syntax (`# zshlint-disable`), NeoVim config, Claude hooks, and test files.

## Solution

Rename all `zshlint` artifacts to follow the `zsh-lint` convention, aligning zsh scripts with the rest of the lint ecosystem. Update all downstream references in cascade: callers, NeoVim config, Claude/AI config, and tests.

## User Stories

1. As a developer, I want `zsh-lint` to follow the same naming pattern as `json-lint` and `css-lint`, so that I can predict any lint script name from the language name alone.
2. As a developer, I want `zsh-lint-shellcheck` and `zsh-lint-custom` to follow the same naming pattern, so that sub-linter names are consistent with the orchestrator.
3. As a developer, I want the inline suppression comment to be `# zsh-lint-disable <code>`, so that it matches the script name it refers to.
4. As a developer, I want the rule function prefix to be `zshLintRule_*` (camelCase with capital L), so that it visually matches the `zsh-lint` script name.
5. As a NeoVim user, I want the linter registered as `zsh-lint` in the nvim-lint config, so that diagnostic sources display the correct name.
6. As a Claude Code user, I want the hooks allowlist to reference `zsh-lint`, `zsh-lint-shellcheck`, and `zsh-lint-custom`, so that Claude can call them without permission prompts.
7. As a Claude Code user, I want the zsh-writer skill to instruct running `zsh-lint <file>`, so that the skill uses the canonical name.
8. As a developer, I want `CLAUDE.md` to document `zsh-lint` as the test command, so that Claude uses the right command when verifying zsh changes.
9. As a developer, I want all BATS test files to reference the scripts by their new names, so that tests remain valid after the rename.
10. As a developer, I want the `lint-zsh` yarn script to call `zsh-lint`, so that pre-commit hooks use the canonical name.
11. As a developer, I want `git-file-lint` to call `zsh-lint`, so that the git lint helper uses the canonical name.

## Implementation Decisions

- **Module A — Core script rename**: The directory `scripts/bin/zsh/zshlint/` becomes `scripts/bin/zsh/zsh-lint/`. The three scripts `zshlint`, `zshlint-shellcheck`, `zshlint-custom` are renamed to `zsh-lint`, `zsh-lint-shellcheck`, `zsh-lint-custom`. Internal variable names inside the orchestrator that reference the sub-linters are updated accordingly.

- **Module B — Rule function prefix**: All 12 rule functions in `__rules/` are renamed from `zshlintRule_*` to `zshLintRule_*`. The `zsh-lint-custom` script that sources and calls these functions is updated. BATS tests for each rule that hardcode the function name via `RULE_FN` are updated.

- **Module C — Suppression syntax**: The inline suppression comment `# zshlint-disable <code>` becomes `# zsh-lint-disable <code>`. The parser in `zsh-lint-custom` that matches this pattern is updated. Rule files that include example suppression comments are updated. BATS tests that use the suppression syntax as test fixtures are updated.

- **Module D — Callers**: `scripts/yarn/lint-zsh` and `tools/term/zsh/config/functions/autoload/git/file/git-file-lint` are updated to call `zsh-lint`.

- **Module E — NeoVim integration**: The linter key, command, and diagnostic source in `filetypes/zsh.lua` are updated from `zshlint` to `zsh-lint`. The linter list in `code-quality.lua` is updated.

- **Module F — Claude/AI config**: `hooks/allowlist.json` entries are updated. The zsh-writer skill step that runs the linter is updated. `CLAUDE.md` testing command is updated.

- **Module G — Tests**: The three orchestrator-level BATS files are renamed. Path references in `bats-test-path.bats` are updated to reflect the new directory and script names.

- **Sequencing**: Module A must complete before Modules B–G, as all other modules depend on the scripts existing under their new names. Modules B–G are independent of each other and can be done in any order after A.

## Testing Decisions

- A good test validates observable behavior (script output, exit codes), not internal implementation details (variable names, function call order).
- **Module A** (script rename): No new tests — the rename is verified by running the existing BATS suite successfully under the new paths.
- **Module B** (function prefix): Existing per-rule BATS tests in `__rules/__tests__/` cover each `zshLintRule_*` function. Update `RULE_FN` references and verify tests still pass.
- **Module C** (suppression syntax): Existing suppression tests in `zsh-lint-custom.bats` cover `# zsh-lint-disable` behavior — update fixture strings only.
- **Modules D–G**: Config and doc changes — no tests (per project convention for config changes).
- Prior art: `scripts/bin/zsh/zshlint/__tests__/` contains canonical examples of orchestrator + sub-linter + rule tests.

## Out of Scope

- Renaming references in `plans/lua/` documents — these reference `zshlint` as historical prior art, not as executable commands.
- Searching for `# zshlint-disable` usage outside this repo.
- Renaming any other lint scripts (`json-lint`, `css-lint`, etc. are already correctly named).
- Changes to linting behavior or rule logic.
