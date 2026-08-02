## Problem Statement

Claude Code sessions have no way to self-terminate. Skills like Ralph (iterative multi-issue implementation) and Plan (PRD + issues) need to stop the session after completing their work, so the user can review, commit, or start the next step. Currently the user must manually Ctrl-C or close the tab.

## Solution

A `claude-stop` ZSH script that terminates the calling Claude Code session from within itself. It does nothing when called by a human or from a subagent — it only kills the main Claude Code session. Two companion helpers (`is-claude`, `is-claude-subagent`) provide reusable detection primitives. Subagent detection is powered by the existing preToolUse-Bash hook injecting an env var when `agent_id` is present in the hook input.

## User Stories

1. As a skill author, I want to call `claude-stop` at the end of a skill, so that the session exits cleanly without user intervention.
2. As a user running Ralph in iterative mode, I want each issue implementation to end with a session stop, so that I can review and commit before the next issue starts.
3. As a user running Plan, I want the session to stop after the PRD and issues are committed, so that I know the planning phase is complete.
4. As a human at the CLI, I want `claude-stop` to be a no-op when I run it directly, so that I don't accidentally kill anything.
5. As a skill author, I want `claude-stop` called from a subagent to be a no-op, so that a subagent can't kill the parent session.
6. As a skill author, I want an `is-claude` helper I can call from any script, so that I can branch behavior based on whether the script runs inside Claude Code.
7. As a skill author, I want an `is-claude-subagent` helper, so that I can branch behavior based on whether the script runs inside a subagent.
8. As a hook author, I want `is-claude-subagent` to document where the env var comes from, so that future maintainers understand the non-obvious injection mechanism.

## Implementation Decisions

- **Detection: am I in Claude?** — check `CLAUDECODE=1` env var (set by Claude Code on all subprocesses)
- **Detection: am I in a subagent?** — check `CLAUDE_IS_SUBAGENT=1` env var, injected by the preToolUse-Bash hook when `agent_id` is present in the hook's stdin JSON. This is NOT a native Claude Code feature; the hook creates it.
- **Injection mechanism** — the preToolUse-Bash hook reads `agent_id` from input JSON. If present, it prefixes the command with `export CLAUDE_IS_SUBAGENT=1;` before passing it to `autoApprove`, `askWithReason`, or `askWithAutoAccept`.
- **PID recovery** — `claude-stop` walks the `/proc/PID/comm` chain from `$PPID` upward looking for a process named `claude`. This is more resilient than hardcoding the grandparent PID.
- **Signal** — SIGTERM (graceful). The `scripts/bin/ai/claude` wrapper has `|| true` so post-exit cleanup (attention icon, terminal fix) runs automatically.
- **Fire-and-forget** — `claude-stop` sends SIGTERM and exits immediately, no wait/retry.
- **Silent guards** — exit 0 with no output when not in Claude or in a subagent.
- **Failure** — exit 1 with stderr message if in main Claude but cannot find the `claude` process in the ancestor chain.
- **Helpers as scripts** — `is-claude` and `is-claude-subagent` are shebang scripts in `scripts/bin/ai/`, not autoloaded functions. Callable from anywhere (hooks, skills, other scripts).
- **Linux-only** — relies on `/proc` filesystem. Acceptable for this setup.

## Testing Decisions

- Tests use the existing bats framework with `bats_run_zsh`, `bats_mock`, `bats_mock_env`.
- **`is-claude`**: test with `CLAUDECODE=1` (exit 0) and without (exit 1).
- **`is-claude-subagent`**: test with `CLAUDE_IS_SUBAGENT=1` (exit 0) and without (exit 1).
- **preToolUse-Bash subagent injection**: test that when input JSON contains `agent_id`, the output command is prefixed with `export CLAUDE_IS_SUBAGENT=1;`. Test that without `agent_id`, command is unchanged.
- **`claude-stop`**: mock `is-claude` and `is-claude-subagent` to test guard behavior. Mock `/proc` to test ppid chain walking. Mock `kill` to verify SIGTERM is sent.
- Prior art: `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats` and `stop.bats`.

## Out of Scope

- Modifying the stop hook sound behavior for subagents (already handled)
- Adding `CLAUDE_IS_SUBAGENT` as a native Claude Code feature (upstream concern)
- macOS support (no `/proc` filesystem)
- Graceful shutdown with wait/retry/SIGKILL fallback

## Further Notes

- The `agent_id` field in hook stdin JSON is officially documented at `code.claude.com/docs/en/hooks`. It is present only when the hook fires inside a subagent.
- Feature requests for native subagent env vars were closed NOT_PLANNED by the Claude Code team (issues #35447, #36981, #46696). The hook injection approach is the community-validated workaround.
- The GLOSSARY.md in `tools/ai/claude/config/hooks/` should be updated to document the new subagent injection concept.
