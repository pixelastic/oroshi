# Claude Code Hooks

Vocabulary for the `preToolUse-Bash` hook pipeline, which gates shell command execution through two sequential decision layers before producing a Claude Code response.

## Language

**Solkan**:
The command validation layer. Two responsibilities: (1) **rewrite** commands per the **rewrite list**, (2) classify each command as **allow** or **reject** per the allowlist. Rewrite always runs first — the allowlist sees the rewritten command.
_Avoid_: allowlist checker, permission layer, gatekeeper

**RTK**:
The command-optimization layer that determines whether a command should be **rewrite**n into its `rtk` equivalent.
_Avoid_: optimizer, command transformer, wrapper

**allow**:
A command cleared by **Solkan** as safe — it can execute without user input.
_Avoid_: permit, whitelist, pass

**reject**:
A command not cleared by **Solkan** — it must go through the user's permission dialog.
_Avoid_: deny, block, blacklist

**rewrite**:
**RTK** has an equivalent for the command and transforms it into its `rtk` form before execution.
_Avoid_: transform, replace, substitute

**rewrite list**:
A JSON map of command names to replacements (e.g. `{"rm": "rm-for-claude"}`), consumed by **Solkan** via `--rewrite-list-file`. Solkan walks the shell AST and replaces matching command names — no matter how deeply nested in pipes, conditionals, or loops — before running allowlist validation.
_Avoid_: replace list, substitution map, rename map

**ignore**:
**RTK** has no equivalent for the command — it is left unchanged.
_Avoid_: skip, pass, leave unchanged

**auto-approve**:
The hook output when Solkan **allow**s a command.
_Avoid_: auto-allow, silent-approve, bypass

**ask with reason**:
The hook output when Solkan **reject**s one or more commands. All rejected binary names are displayed, every time. The user sees a 2-option dialog (Allow / Deny). Maps to `permissionDecision: "ask"`.
_Avoid_: ask user, escalate, warn-ask

**subagent injection**:
The mechanism by which the preToolUse-Bash hook detects that a command runs inside a subagent (`agent_id` present in hook input JSON) and prefixes the command with `export CLAUDE_IS_SUBAGENT=1;`. This is NOT a native Claude Code feature — it is a hook-level workaround because upstream closed requests for native subagent env vars (issues #35447, #36981, #46696).
_Avoid_: subagent detection, agent env var, subagent flag

## Relationships

- **Solkan** has two phases: **rewrite list** (substitute command names in AST) then allowlist (**allow** or **reject**). The allowlist decision is binary — never partial.
- **Solkan** runs first; **RTK** runs second, regardless of **Solkan**'s decision.
- Rewrite determined via `rtk-command-rewrite <cmd>`: prints the rewritten command (or the original unchanged). Always exits 0.
- Each command receives exactly one **Solkan** decision and exactly one **RTK** decision.
- Each **allow** produces exactly one **auto-approve**; each **reject** produces exactly one **ask with reason** (a maybe — the human decides).
- A **rewrite** produces zero or one `updatedInput` JSON field; an **ignore** produces none.
- The human is the only actor who can say a final "no" — through the **ask with reason** dialog.

### The 4 cases

| Solkan | RTK | Hook output |
|--------|-----|-------------|
| allow | rewrite | auto-approve + updatedInput |
| allow | ignore | auto-approve (no updatedInput) |
| reject | rewrite | ask with reason + updatedInput |
| reject | ignore | ask with reason (no updatedInput) |

## Design decisions

### Why rewrite both in the hook and in Solkan

The hook does global command rewriting via RTK (prepends `rtk bin-zsh` to the entire command).

Solkan parses the full shell AST (via unbash) to extract every simple command and rewrite them individually (`rm` replaces to `rm-for-claude` for example).

## Flagged ambiguities

- **allow** (Solkan decision) vs **auto-approve** (hook output): distinct layers — Solkan classifies the command; the hook translates that into a Claude Code response.
- **reject** (Solkan decision) vs **ask with reason** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user".
