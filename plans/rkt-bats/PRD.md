## Problem Statement

When Claude runs a `bats` test command, the preToolUse hook does not transparently rewrite it to `rtk bats`. RTK's built-in `rewrite` command only knows about its own built-in subcommands (git, npm, vitest…) — it ignores custom TOML-defined filters such as `[filters.bats]` in `~/.config/rtk/filters.toml`. As a result, bats output lands in Claude's context unfiltered, consuming tokens for passing tests that are irrelevant.

The current workaround — telling Claude to explicitly write `rtk bats` in skills and CLAUDE.md — is fragile and leaks an implementation detail into every instruction.

## Solution

Introduce a dedicated `rtk-can-rewrite` autoloaded function that extends RTK's rewrite check to also cover TOML-defined custom filters. The preToolUse hook delegates its RTK decision to this function. Skills and documentation revert to plain `bats`, trusting the hook to handle the optimization transparently.

## User Stories

1. As Claude, I want to run `bats foo.bats` and have it automatically proxied through RTK, so that only failures reach my context.
2. As Claude, I want to run `git status` and have it automatically rewritten to `rtk git status`, so that compact output is used.
3. As Claude, I want to run `echo hello` and have it pass through unchanged, so that RTK is not applied to commands it cannot improve.
4. As a developer, I want `rtk-can-rewrite` usable outside of the hook context, so that other scripts can check RTK rewrite eligibility without duplicating logic.
5. As a developer, I want skill instructions to say `bats <filepath>` without any RTK prefix, so that the instructions describe intent rather than implementation.
6. As a developer, I want the GLOSSARY to accurately describe how the RTK layer determines rewrite eligibility, so that future contributors understand the mechanism.

## Implementation Decisions

- `rtk-can-rewrite` is a zsh autoloaded function (not a hook script), placed in the `ai/rtk` subdomain of the autoload tree. This makes it reusable across any zsh context.
- Interface: takes one argument (the full command string), exits 0 if RTK can handle it, exits 1 otherwise. No stdout output.
- Internal logic (in order): first delegates to `rtk rewrite`; if that returns no output, falls back to parsing the TOML filters file and checking if the command's first word matches any `[filters.NAME]` section name.
- TOML parsing uses grep to extract section names (`[filters.NAME]` → `NAME`). No external TOML parser required.
- `RTK_CMD` env var overrides the rtk binary path (default: `rtk`). `RTK_FILTERS_TOML` env var overrides the filters file path (default: `~/.config/rtk/filters.toml`). Both exist for test isolation within the function's own test suite.
- `preToolUse-Bash-rtk` is updated to call `rtk-can-rewrite` instead of `rtk rewrite` directly. If exit 0, it prepends `rtk` to the command. `RTK_CAN_REWRITE_CMD` env var overrides the function path for test isolation at the hook level.
- Skills and CLAUDE.md that currently say `rtk bats <filepath>` are updated to say `bats <filepath>`.
- `GLOSSARY.md` Layer 2 section is updated: "Determined via `rtk rewrite`" becomes "Determined via `rtk-can-rewrite`".

## Testing Decisions

Good tests check external behavior only — exit codes and outputs, not internal implementation. Tests use real binaries (RTK, bats) rather than mocks where the subject under test is the integration itself.

**Module A — `rtk-can-rewrite`:** integration tests with the real RTK binary and the real deployed `~/.config/rtk/filters.toml`. Three cases: built-in command (exit 0), TOML-filtered command (exit 0), unrecognized command (exit 1). No test for missing TOML file.

**Module B — `preToolUse-Bash-rtk`:** unit tests that mock `RTK_CAN_REWRITE_CMD` to control the yes/no decision in isolation. Three cases: mock exits 0 → command prefixed with `rtk`; mock exits 1 → command unchanged; command already starts with `rtk` → passes through without calling `rtk-can-rewrite`. Existing tests are replaced to reflect the new interface.

Prior art: `hooks/__tests__/preToolUse-Bash-rtk.bats` (existing mock pattern with `printf` scripts).

## Out of Scope

- Making `rtk rewrite` itself TOML-aware (upstream RTK change).
- Handling compound commands (`bats foo && echo done`): the hook already passes these through unchanged today.
- Testing the case where the TOML file does not exist.

## Further Notes

The `rtk-can-rewrite` function name follows the RTK layer vocabulary from the GLOSSARY: RTK either **rewrites** or **ignores** a command. The `can-rewrite` form expresses the boolean nature of the check.
