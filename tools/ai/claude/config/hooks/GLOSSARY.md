# Claude Code Hooks

Vocabulary for the Claude Code hooks. The Bash pipeline: `preToolUse-Bash` gates shell command execution through Solkan before producing a Claude Code response; `postToolUse-Bash` counts the approvals the user gave. The Stop / SubagentStop hooks decide whether to notify when Claude Code finishes a turn.

## Language

**Solkan**:
The command validation layer. Two responsibilities: (1) **rewrite** commands per the **rewrite list**, (2) classify each command as **allow** or **reject** per the allowlist. Rewrite always runs first — the allowlist sees the rewritten command.
_Avoid_: allowlist checker, permission layer, gatekeeper

**allow**:
A command cleared by **Solkan** as safe — it can execute without user input.
_Avoid_: permit, whitelist, pass

**reject**:
A command not cleared by **Solkan** — it must go through the user's permission dialog.
_Avoid_: deny, block, blacklist

**rewrite**:
**Solkan** replaces a command name with its configured equivalent (per the **rewrite list**) before the allowlist sees it.
_Avoid_: transform, replace, substitute

**rewrite list**:
A JSON map of command names to replacements (e.g. `{"rm": "rm-for-claude"}`), consumed by **Solkan** via `--rewrite-list-file`. Solkan walks the shell AST and replaces matching command names — no matter how deeply nested in pipes, conditionals, or loops — before running allowlist validation.
_Avoid_: replace list, substitution map, rename map

**auto-approve**:
The hook output when Solkan **allow**s a command.
_Avoid_: auto-allow, silent-approve, bypass

**ask with reason**:
The hook output when Solkan **reject**s one or more commands. All rejected binary names are displayed, every time, each followed by a moon showing its **approval count**: no symbol on the 1st prompt, `🌓` on the 2nd, `🌕` on the 3rd (e.g. `❌ /usr/bin/grep 🌕, wget ❌`). Approving a `🌕` command adds it to the **session allow-list**. The user sees a 2-option dialog (Allow / Deny). Maps to `permissionDecision: "ask"`.
_Avoid_: ask user, escalate, warn-ask

**approval pending**:
The rejected commands of an **ask with reason** dialog, waiting for the user's answer. Removed once the user approves; entries for prompts the user denies are never cleaned.
_Avoid_: asked commands, pending list, queue

**approval count**:
How many times, in the current session, the user approved a given rejected command. Stored in the session state under `.postToolUse.Bash.approvalCount`, keyed by the rejected command as Solkan reports it (binary name or path, e.g. `wget`, `/usr/bin/grep`).
_Avoid_: accept count, allow count, approval score

**session allow-list**:
A regular Solkan allow-list (JSON array of strings, same format as `allow-list.json`) scoped to the current session, at `$CLAUDE_SESSIONS_DIR/$CLAUDE_SESSION_ID/allow-list.json`. A command enters it on its 3rd approval, keyed as Solkan reports it. Passed to Solkan as an extra `--allow-list-file` (absolute path) when it exists; a command in it is an **allow** like any other.
_Avoid_: session whitelist, temporary allow, trusted commands

**tool use id**:
The `tool_use_id` field of the hook input JSON. Identical in the pre and post events of the same Bash call — the only reliable way to correlate them, since post events receive the rewritten command.
_Avoid_: call id, request id

**subagent injection**:
The mechanism by which the preToolUse-Bash hook detects that a command runs inside a subagent (`agent_id` present in hook input JSON) and prefixes the command with `export CLAUDE_IS_SUBAGENT=1;`. This is NOT a native Claude Code feature — it is a hook-level workaround because upstream closed requests for native subagent env vars (issues #35447, #36981, #46696).
_Avoid_: subagent detection, agent env var, subagent flag

**pending subagent**:
An entry of the Stop / SubagentStop hook stdin `background_tasks` array with `type == "subagent"`, still listed when Stop fires. Its presence makes the Stop hook skip the notification. The `background_tasks` field is undocumented upstream; observed in Claude Code 2.1.280.
_Avoid_: running subagent, active agent, live subagent

## Relationships

- **Solkan** has two phases: **rewrite list** (substitute command names in AST) then allowlist (**allow** or **reject**). The allowlist decision is binary — never partial.
- Each command receives exactly one **Solkan** decision.
- Each **allow** produces exactly one **auto-approve**; each **reject** produces exactly one **ask with reason** (a maybe — the human decides).
- A **rewrite** produces one `updatedInput` JSON field; a command left unchanged produces none.
- The human is the only actor who can say a final "no" — through the **ask with reason** dialog.
- Each **ask with reason** writes one **approval pending** entry (`preToolUse-Bash`), keyed by its **tool use id** so the post event can find it; each **allow** writes none.
- A post event (`PostToolUse` or `PostToolUseFailure`) for a **tool use id** means the user said Yes: `postToolUse-Bash` increments the **approval count** of every command in its **approval pending** entry, then removes that entry. When the user says No, no post event fires, so no count changes.
- A command whose **approval count** reaches 3 joins the **session allow-list**: from then on, Solkan **allow**s it and it no longer appears in **ask with reason**.
- Session state lives in `$CLAUDE_SESSIONS_DIR/$CLAUDE_SESSION_ID/state.json`, the **session allow-list** next to it; both owned by `Bash-approval.zsh`. Without a session id, nothing is recorded.
- A Stop with at least one **pending subagent** never notifies; any other `background_tasks` entry never blocks it.

## Flagged ambiguities

- **allow** (Solkan decision) vs **auto-approve** (hook output): distinct layers — Solkan classifies the command; the hook translates that into a Claude Code response.
- **reject** (Solkan decision) vs **ask with reason** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user".
