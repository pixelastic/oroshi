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

**ask user — first time**:
The hook output when Solkan **reject**s a command that has never been seen in the current session, or when multiple binaries are rejected at once. The user sees a 2-option dialog (Allow / Deny) with the rejected binary name(s) displayed. Maps to `permissionDecision: "ask"`.
_Avoid_: ask, first-ask, new-ask, warn-ask

**ask user**:
The hook output when Solkan **reject**s a command that has already been seen in the current session. The user sees a 3-option dialog: Allow / Allow for session / Deny. No reason is shown — the user has already been informed. Maps to `permissionDecision: "defer"`.
_Avoid_: escalate, defer, session-ask

## Relationships

- **Solkan** is binary: **allow** or **reject**. Never a partial decision.
- **Solkan** runs first; **RTK** runs second, regardless of **Solkan**'s decision.
- Determined via `rtk rewrite <cmd>`: exit 0 = **rewrite**, exit 1 = **ignore**.
- Each command receives exactly one **Solkan** decision and exactly one **RTK** decision.
- Each **allow** produces exactly one **auto-approve**; each **reject** produces either **ask user** or **ask user — first time** depending on session state (a maybe — the human decides).
- A **rewrite** produces zero or one `updatedInput` JSON field; an **ignore** produces none.
- The human is the only actor who can say a final "no" — and only in the **ask user** path.

### The 4 cases

| Solkan | RTK | Hook output |
|--------|-----|-------------|
| allow | rewrite | auto-approve + updatedInput |
| allow | ignore | auto-approve (no updatedInput) |
| reject | rewrite | ask user / ask user — first time + updatedInput |
| reject | ignore | ask user / ask user — first time (no updatedInput) |

## Design decisions

### Why `ask user` and `ask user — first time` are two distinct outputs

The natural design would be a single reject path with a 3-option dialog (Allow / Allow for session / Deny) that always displays the rejected binary name — so the user knows why they are being asked, whether it is the first time or not.

This is not possible. Claude Code only displays the binary name(s) when `permissionDecision` is `"ask"`. When `permissionDecision` is `"defer"`, the reason field is silently ignored and the binary name is not shown. The two `permissionDecision` values also map to different dialog types: `"ask"` produces a 2-option dialog (Allow / Deny); `"defer"` produces a 3-option dialog (Allow / Allow for session / Deny).

As a result:
- **First-time reject** uses `permissionDecision: "ask"` to surface the binary name, at the cost of losing the "Allow for session" option.
- **Repeat reject** uses `permissionDecision: "defer"` to offer "Allow for session", accepting that the binary name is not shown (the user was already informed on the first ask).

The split is a workaround for this Claude Code limitation, not an intentional UX design.

## Flagged ambiguities

- **allow** (Solkan decision) vs **auto-approve** (hook output): distinct layers — Solkan classifies the command; the hook translates that into a Claude Code response.
- **reject** (Solkan decision) vs **ask user** / **ask user — first time** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user"; session state determines which dialog appears.
