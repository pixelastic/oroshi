# PRD — Unified PreToolUse-Bash Hook

## Problem Statement

Two independent Claude Code PreToolUse hooks run in parallel for Bash commands:

1. **Tim's hook** (`preToolUse-Bash` via `solkan`) — decides whether to auto-approve or ask the user
2. **RTK hook** (`rtk-rewrite.sh`) — rewrites commands to token-efficient equivalents

Because Claude Code runs all matching hooks in parallel and each receives the original stdin, RTK's `updatedInput` rewrites are silently discarded. Token savings from RTK never take effect for Bash commands in practice.

## Solution

Replace the two-hook system with a single unified `preToolUse-Bash` that treats permission and command rewriting as **two orthogonal concerns**:

1. `preToolUse-Bash-solkan "$cmd"` → exit 0 (auto-allow) or exit 1 (ask user)
2. `preToolUse-Bash-rtk "$cmd"` → stdout: final command (original or rewritten)
3. `preToolUse-Bash` merges both results into a single `hookSpecificOutput` JSON

This produces **4 valid output cases**:

| Solkan | RTK | JSON output |
|---|---|---|
| allow | unchanged | `permissionDecision: allow` |
| allow | rewritten | `permissionDecision: allow` + `updatedInput` |
| ask | unchanged | *(no permissionDecision)* |
| ask | rewritten | `updatedInput` only |

Remove the RTK hook entry from `settings.json` and delete `rtk-rewrite.sh`.

## User Stories

1. As Claude, when I run `git status`, I receive compact `rtk git status` output so that I use fewer tokens.
2. As Tim, when Claude runs an allowlisted command, it auto-approves without prompting — even after RTK rewrites it.
3. As Tim, when Claude runs a non-allowlisted command, I am prompted for confirmation. If RTK knows how to rewrite it, I see the rewritten version for confirmation.
4. As Tim, I can inject mock subscripts via env vars to test `preToolUse-Bash` JSON output in isolation.

## Implementation Decisions

- **Solkan checks the original command**, not the RTK-rewritten one. Security gate runs first on Claude's intent.
- **RTK is called unconditionally** — both subscripts always run, regardless of each other's result.
- **RTK's own logic handles complex commands** (pipes, `&&`, `;`) — no special casing in the hook.
- **Only RTK exit 0 matters** — any other exit code means no rewrite; subscript prints original command unchanged.
- **Dependency injection** via `PRETOOLUSE_SOLKAN_SCRIPT` and `PRETOOLUSE_RTK_SCRIPT` env vars. Default to real scripts; override in tests with mock scripts.
- **`preToolUse-Bash` builds JSON directly with `jq`** — does not use `acceptTool()` from `hookLib.zsh`, which has no `updatedInput` support.
- **`updatedInput` is included only when RTK actually rewrote** — detected by comparing `preToolUse-Bash-rtk` stdout against the original command.
- **`updatedInput` preserves the full original `tool_input`** (including `description` and other fields), updating only the `command` field.
- **`rtk-rewrite.sh` is deleted** — it was a standalone hook; its logic does not transfer to the subscript architecture.

## Testing Decisions

- `preToolUse-Bash-solkan`: unit tests with the real `solkan` binary against known allowlist entries (allow and deny cases, simple and compound commands).
- `preToolUse-Bash-rtk`: unit tests with the real `rtk` binary for known rewritable and non-rewritable commands.
- `preToolUse-Bash`: integration tests using **mock scripts injected via env vars** — one test per output case in the 4-case matrix. No real solkan or rtk involved.

## Out of Scope

- Changes to `preToolUse` dispatcher
- Changes to `hookLib.zsh`
- Changes to `preToolUse-mcp` or `preToolUse-Skill`
- RTK availability or version guards (rtk is installed and working)
- Handling RTK exit codes 2 and 3 explicitly (deny/ask arrays are empty; dead paths)
