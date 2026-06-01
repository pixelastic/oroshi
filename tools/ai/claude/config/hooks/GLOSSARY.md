# Claude Code Hooks

Vocabulary for the `preToolUse-Bash` hook pipeline, which gates shell command execution through two sequential decision layers before producing a Claude Code response.

## Language

**Solkan**:
The allowlist-based decision layer that classifies a command as **allow** or **reject**.
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

**ignore**:
**RTK** has no equivalent for the command — it is left unchanged.
_Avoid_: skip, pass, leave unchanged

**auto-approve**:
The hook output when Solkan **allow**s a command.
_Avoid_: auto-allow, silent-approve, bypass

**ask user**:
The hook output when Solkan **reject**s a command.
_Avoid_: prompt, defer, ask

## Relationships

- **Solkan** is binary: **allow** or **reject**. Never a partial decision.
- **Solkan** runs first; **RTK** runs second, regardless of **Solkan**'s decision.
- Determined via `rtk rewrite <cmd>`: exit 0 = **rewrite**, exit 1 = **ignore**.
- Each command receives exactly one **Solkan** decision and exactly one **RTK** decision.
- Each **allow** produces exactly one **auto-approve**; each **reject** produces exactly one **ask user** (a maybe — the human decides).
- A **rewrite** produces zero or one `updatedInput` JSON field; an **ignore** produces none.
- The human is the only actor who can say a final "no" — and only in the **ask user** path.

### The 4 cases

| Solkan | RTK | Hook output |
|--------|-----|-------------|
| allow | rewrite | auto-approve + updatedInput |
| allow | ignore | auto-approve (no updatedInput) |
| reject | rewrite | ask user + updatedInput |
| reject | ignore | ask user (no updatedInput) |

## Flagged ambiguities

- **allow** (Solkan decision) vs **auto-approve** (hook output): distinct layers — Solkan classifies the command; the hook translates that into a Claude Code response.
- **reject** (Solkan decision) vs **ask user** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user".
