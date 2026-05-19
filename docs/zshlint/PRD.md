# PRD — zshlint Custom Rules

## Problem Statement

`zshlint` enforces shellcheck rules on ZSH files, but the zsh-writer style guide
defines several conventions that shellcheck cannot check — either because shellcheck
has no rule for them, or because shellcheck's rule does the opposite (e.g. SC2155
discourages combining `local` and assignment, whereas the style guide requires it).

As a result, style violations slip through undetected. When an AI agent writes or
modifies ZSH code, it has no automated signal that it has violated a style rule —
only the human reviewer catches it, too late.

## Solution

Extend `zshlint` with Custom Rules: ZSH functions that scan files for style
violations not covered by shellcheck, output results in the same JSON format,
and are merged with shellcheck's output into a single array consumed by both
NeoVim (inline diagnostics) and AI agents (automated fixes).

The Orchestrator (`zshlint`) is refactored into a directory containing the entry
point script and a set of Lib Files — one per Custom Rule. The external interface
of `zshlint` is unchanged.

## User Stories

1. As a developer, I want `zshlint` to flag `local a b c` grouped declarations, so that I am reminded to declare each variable on its own `local` line.
2. As a developer, I want `zshlint` to flag `local foo="$(cmd)" || return`, so that I am reminded that `local` always returns 0 and the guard is silently ineffective.
3. As a developer, I want `zshlint` to flag `$(basename ...)`, `$(dirname ...)`, and `$(realpath ...)`, so that I am reminded to use ZSH modifiers (`:t`, `:h`, `:a`) instead.
4. As a developer, I want `zshlint` to flag `while read` loops, so that I am reminded to use ZSH-native `${(f)var}` iteration instead.
5. As a developer, I want `zshlint` to flag `shift` used for argument parsing, so that I am reminded to use `zparseopts` instead.
6. As a developer, I want `zshlint` to flag `=` used instead of `==` inside `[[ ]]`, so that comparisons are consistent.
7. As a developer, I want `zshlint` to flag `else` blocks as a warning, so that I am prompted to consider the return-early pattern.
8. As a developer, I want custom rule violations to appear inline in NeoVim alongside shellcheck diagnostics, so that I have a single unified lint experience.
9. As an AI agent, I want custom rule violations to include the file path, rule code, severity, line number, and message, so that I can locate and fix each violation without additional context.
10. As a developer, I want to disable a custom rule by commenting out one line in the Orchestrator, so that I can suppress a rule temporarily without deleting code.
11. As a developer, I want each custom rule to be unit-testable in isolation, so that I can verify its behavior against specific inputs without running the full lint pipeline.
12. As a developer, I want the Orchestrator to be tested for JSON conversion and merge behavior, so that I can verify custom rule output is correctly combined with shellcheck output.
13. As a developer, I want tests co-located with the code they test, so that the test and its subject are always found together.

## Implementation Decisions

### Architecture

`zshlint` is refactored from a single script into a directory. The directory is
automatically added to PATH by the existing `path.zsh` recursive glob. The entry
point script retains the same name and external interface.

Two subdirectories are excluded from PATH via the `__` prefix convention:
- `__rules/` — Lib Files, one per Custom Rule
- `__tests__/` — bats test files, one per Custom Rule plus one for the Orchestrator

### Orchestrator responsibilities

The refactored Orchestrator:
1. Sources all Lib Files at startup (static, ordered list — comment a line to disable)
2. Runs shellcheck and captures its JSON output (with `|| true` to avoid `set -e` abort)
3. For each input file, calls each Custom Rule function in sequence
4. Collects all Rule Output lines
5. Converts Rule Output lines to JSON objects (with default values for unused fields)
6. Merges custom JSON with shellcheck JSON via `jq`
7. Outputs the merged JSON array to stdout
8. Exits 1 if shellcheck found errors or any custom violations were found

### Custom Rule interface

Each Lib File defines exactly one function. The function takes a file path as its
single argument and writes zero or more Rule Output lines to stdout.

**Rule Output format:** `file▮code▮level▮line▮message`

- `file`: path to the scanned file (required by AI agents)
- `code`: integer in the `9####` range
- `level`: `error` | `warning` | `style`
- `line`: 1-based line number
- `message`: human-readable description of the violation

Fields not in Rule Output are defaulted in the JSON: `column=1`, `endLine=line`, `endColumn=1`.

### Custom Rule naming conventions

- Lib File: `__rules/rule-{slug}.zsh` (kebab-case slug)
- Function: `zshlintRule_{CamelCaseName}()` (namespace prefix + camelCase)

### Custom Rules

| Code  | Function                         | Level   | Rule |
|-------|----------------------------------|---------|------|
| 90001 | `zshlintRule_noGroupedLocals`    | warning | No grouped `local` declarations (`local a b c`) |
| 90002 | `zshlintRule_localOrReturn`      | error   | No `\|\|` chained on a `local` line |
| 90003 | `zshlintRule_noExternalBasename` | style   | Prefer `:t`/`:h`/`:a` over `$(basename/dirname/realpath)` |
| 90004 | `zshlintRule_noWhileRead`        | warning | No `while read` loops |
| 90005 | `zshlintRule_noShift`            | warning | No `shift` for argument parsing |
| 90006 | `zshlintRule_singleEqualsInTest` | style   | Use `==` not `=` inside `[[ ]]` |
| 90007 | `zshlintRule_elseSmell`          | warning | `else` blocks suggest a missing return-early |

### JSON output compatibility

The JSON output format is unchanged from the current `zshlint`. The nvim linter
parser (`zsh.lua`) already handles all required fields. Custom rule codes appear
as `SC90001` etc. in the nvim diagnostic display — no changes to the nvim config
are needed.

### Rule implementation process

Before implementing each Custom Rule, the agent must run a `grill-me` session with
the user to reach shared understanding of:
- What the rule detects (precise definition)
- Examples that should trigger the rule (true positives)
- Examples that should NOT trigger the rule (false positives to avoid)
- Edge cases specific to that rule's regex

This session produces the test cases before any code is written.

## Testing Decisions

### What makes a good test

Tests verify external behavior only: given a file with specific content, does the
rule function output the expected Rule Output line(s) — or no output when the
content is valid? Tests do not inspect regex internals.

### Modules tested

**Custom Rule Lib Files (unit tests):** Each rule function is tested in isolation
by sourcing its Lib File directly and calling the function with a temporary fixture
file. One bats file per rule.

**Orchestrator (integration tests):** The Orchestrator is tested end-to-end:
given a file with known violations, verify the merged JSON output contains the
expected objects (both from shellcheck and from custom rules). Verify that a
clean file produces an empty array. Verify exit code behavior.

### Test file location

Tests are co-located in `__tests__/` within the zshlint directory. Each test
file loads the global bats helper via a relative path to `scripts/bin/__tests__/helper`.

### Prior art

Existing bats tests in `scripts/bin/__tests__/` follow the same pattern:
`setup()` creates a temp directory via `bats_tmp`, tests write fixture content
to files in that directory, and `run` captures command output for assertions.

## Out of Scope

- **Automated fixes (`fix` field):** Custom rules will not provide fix suggestions. Detection only.
- **Long-form argument enforcement:** Too many false positives; no reliable universal mapping from short to long flags. Remains a style guideline only.
- **Naming convention enforcement** (`isSomething`, `UPPER_CASE`): Requires semantic understanding beyond static analysis.
- **Nesting depth / complexity metrics:** Too imprecise as a grep heuristic; high false positive rate.
- **One-arg-per-line enforcement:** Not automatable reliably.
- **ShellCheck Custom.hs extension:** Requires Haskell and compiling shellcheck from source.

## Further Notes

The CONTEXT.md for this feature defines the shared vocabulary used throughout
implementation. It lives at `scripts/bin/zsh/zshlint/CONTEXT.md` alongside the code.

The `else` smell rule (90007) is intentionally at `warning` level because it has
a higher false positive rate than other rules — not every `else` block is wrong,
but each one is worth a second look.
