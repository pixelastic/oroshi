# Claude Code Hooks

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
A map of command names to their replacements (e.g. `{"rm": "rm-guarded"}`), applied by **Solkan** wherever the command name appears.
_Avoid_: replace list, substitution map, rename map

**single command**:
A command string for which **Solkan** reports exactly one command.
_Avoid_: simple command, lone command, plain command

**compound command**:
Any command string for which **Solkan** reports zero or several commands (pipe, chain of different binaries, command substitution).
_Avoid_: complex command, chained command, pipeline

**token-saving rewrite list**:
A **rewrite list** that maps commands to their **token-saving wrapper** only (e.g. `{"zsh-test": "zsh-test-token-saving"}`). It applies to a **single command** only, on top of the regular **rewrite list**.
_Avoid_: output list, short list, quiet list

**token-saving wrapper**:
A `<command>-token-saving` function that runs `<command>` with reduced output. It changes the output format only.
_Avoid_: quiet wrapper, filter, compressor

**auto-approve**:
The hook output that lets a tool call proceed without prompting the user. Maps to `permissionDecision: "allow"`.
_Avoid_: auto-allow, silent-approve, bypass

**ask with reason**:
The hook output that hands a tool call to the user for a decision (Allow / Deny) and names every rejected command. Each name carries a moon showing its **approval count**: no symbol at count 0, `🌓` at 1, `🌕` at 2 or more (e.g. `❌ /usr/bin/grep 🌕, wget ❌`). Maps to `permissionDecision: "ask"`.
_Avoid_: ask user, escalate, warn-ask

**approval request**:
The rejected commands of an **ask with reason** dialog, waiting for the user's answer. `preToolUse-Bash` opens it, `postToolUse-Bash` closes it.
_Avoid_: approval pending, asked commands, pending list, queue

**approval count**:
How many times, in the current session, the user approved a given rejected command.
_Avoid_: accept count, allow count, approval score

**session allow-list**:
An allow-list scoped to the current session. A command enters it on its 3rd approval; a command in it is an **allow** like any other.
_Avoid_: session whitelist, temporary allow

**approval memory**:
What the hooks remember of the user's approvals of rejected commands. It owns the **approval request** entries, the **approval count** and the **session allow-list**.
_Avoid_: trusted commands, command trust, learning

**guarded**:
A command from the **rewrite list** that checks what it is asked to do (e.g. `rm-guarded`). It may refuse to act.
_Avoid_: safe command, wrapped command, protected command

**guarded refusal**:
A **guarded** command declining to act. It says so with a **refusal line** in its output, and `postToolUse-Bash` reports it to Claude.
_Avoid_: guarded block, guarded error, guarded rejection

**refusal line**:
A line of a command output that starts with the **refusal prefix**. The rest of the line is the message for Claude.
_Avoid_: marker, marker line, refusal message

**refusal prefix**:
The text `[claude-guarded:refused]` that starts every **refusal line**.
_Avoid_: marker prefix, guard tag

**report**:
Giving the messages of the **refusal lines** to Claude, as the `additionalContext` of the post event.
_Avoid_: relay, forward, surface

**auto allow-list**:
An allow-list of additional commands, for when ralph runs in auto mode.
_Avoid_: ralph allow-list, interpreter list, auto-mode whitelist

**tool use id**:
The identifier of one tool call. It is the same in the pre and post events of that call, so it links them.
_Avoid_: call id, request id

**subagent injection**:
Marking a command as run by a subagent, so the command can tell it apart from one run by the main agent.
_Avoid_: subagent detection, agent env var, subagent flag

**pending subagent**:
A subagent still running when the Stop hook fires. Its presence makes the Stop hook skip the notification.
_Avoid_: running subagent, active agent, live subagent

## Relationships

- **Solkan** has two phases: **rewrite list** (substitute command names in AST) then allowlist (**allow** or **reject**). The allowlist decision is binary — never partial.
- The regular **rewrite list** always applies, guard-rails included. For a **single command**, the **token-saving rewrite list** is added after it and overrides it on conflict; for a **compound command**, it is not passed. `preToolUse-Monitor` never passes it, even for a **single command**.
- `preToolUse-Monitor` produces **auto-approve** on **allow** and **ask with reason** on **reject**. It writes no **approval request** entry and keeps no **approval count**, so **approval memory** never counts a `Monitor` command. Monitor still honours the **session allow-list**.
- Each command receives exactly one **Solkan** decision.
- Each **allow** produces exactly one **auto-approve**; each **reject** produces exactly one **ask with reason** (a maybe — the human decides).
- A **rewrite** produces one `updatedInput` JSON field; a command left unchanged produces none.
- The human is the only actor who can say a final "no" — through the **ask with reason** dialog.
- Each **ask with reason** opens an **approval request** (`preToolUse-Bash`, one entry per rejected command), keyed by its **tool use id** so the post event can find it; each **allow** writes none.
- A post event (`PostToolUse` or `PostToolUseFailure`) for a **tool use id** means the user said Yes: `postToolUse-Bash` increments the **approval count** of every command in its **approval request**, then closes that request. When the user says No, no post event fires, so no count changes.
- **Approval memory** joins the two hooks of the Bash pipeline: `preToolUse-Bash` opens the **approval request**, `postToolUse-Bash` counts.
- A command whose **approval count** reaches 3 joins the **session allow-list**: from then on, Solkan **allow**s it and it no longer appears in **ask with reason**.
- A **guarded refusal** is not a **reject**: Solkan already allowed the command, and the **guarded** command itself declined to act. `lib/guarded.zsh` owns the **refusal prefix** and the **report**; the hook decides when to **report**.
- The **auto allow-list** is added to the regular allow-list only while the ralph session of the session directory runs in `auto` mode.
- Session state lives in `$CLAUDE_SESSION_DIR/state.json`, the **session allow-list** next to it; both owned by `lib/approval-memory.zsh`. Without a session id, nothing is recorded.
- A Stop with at least one **pending subagent** never notifies; any other `background_tasks` entry never blocks it.

## Flagged ambiguities

- **allow** (Solkan decision) vs **auto-approve** (hook output): distinct layers — Solkan classifies the command; the hook translates that into a Claude Code response.
- **reject** (Solkan decision) vs **ask with reason** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user".
