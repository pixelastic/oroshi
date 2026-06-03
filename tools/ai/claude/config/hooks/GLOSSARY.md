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

**ask with reason**:
The hook output when Solkan **reject**s one or more commands and at least one has never been seen in the current session. Only the new binary names are displayed. The user sees a 2-option dialog (Allow / Deny). Maps to `permissionDecision: "ask"`.
_Avoid_: ask user — first time, first-ask, new-ask, warn-ask

**ask with auto-accept**:
The hook output when Solkan **reject**s one or more commands and all have already been seen in the current session. The user sees a 3-option dialog: Allow / Allow for session / Deny. No reason is shown — the user has already been informed. Maps to `permissionDecision: "defer"`.
_Avoid_: ask user, escalate, defer, session-ask

## Relationships

- **Solkan** is binary: **allow** or **reject**. Never a partial decision.
- **Solkan** runs first; **RTK** runs second, regardless of **Solkan**'s decision.
- Determined via `rtk rewrite <cmd>`: exit 0 = **rewrite**, exit 1 = **ignore**.
- Each command receives exactly one **Solkan** decision and exactly one **RTK** decision.
- Each **allow** produces exactly one **auto-approve**; each **reject** produces either **ask with reason** or **ask with auto-accept** depending on session state (a maybe — the human decides).
- A **rewrite** produces zero or one `updatedInput` JSON field; an **ignore** produces none.
- The human is the only actor who can say a final "no" — in both the **ask with reason** and **ask with auto-accept** paths.

### The 4 cases

| Solkan | RTK | Hook output |
|--------|-----|-------------|
| allow | rewrite | auto-approve + updatedInput |
| allow | ignore | auto-approve (no updatedInput) |
| reject | rewrite | ask with reason / ask with auto-accept + updatedInput |
| reject | ignore | ask with reason / ask with auto-accept (no updatedInput) |

## Design decisions

### Why `ask with reason` and `ask with auto-accept` are mutually exclusive

The natural design would be a single reject path with a 3-option dialog (Allow / Allow for session / Deny) that always displays the rejected binary name — reason and auto-accept together, every time.

This is not possible. Claude Code only displays the binary name(s) when `permissionDecision` is `"ask"`. When `permissionDecision` is `"defer"`, the reason field is silently ignored and the binary name is not shown. The two `permissionDecision` values also map to different dialog types: `"ask"` produces a 2-option dialog (Allow / Deny); `"defer"` produces a 3-option dialog (Allow / Allow for session / Deny).

As a result, each reject must choose one or the other:
- **ask with reason** (`permissionDecision: "ask"`) — surfaces the binary name so the user knows what is blocked, at the cost of losing the "Allow for session" option.
- **ask with auto-accept** (`permissionDecision: "defer"`) — offers "Allow for session", at the cost of not displaying the binary name (the user was already informed on the first ask).

The split is a workaround for this Claude Code limitation, not an intentional UX design.

## Flagged ambiguities

- **allow** (Solkan decision) vs **auto-approve** (hook output): distinct layers — Solkan classifies the command; the hook translates that into a Claude Code response.
- **reject** (Solkan decision) vs **ask with reason** / **ask with auto-accept** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user"; session state determines which dialog appears.
