# Approval

How the hooks answer Claude Code about a tool call, and what they remember of the user's answers.

## Language

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

**tool use id**:
The identifier of one tool call. It is the same in the pre and post events of that call, so it links them.
_Avoid_: call id, request id

## Relationships

- Each **allow** (see [Solkan](./solkan.md)) produces exactly one **auto-approve**; each **reject** produces exactly one **ask with reason** (a maybe — the human decides).
- The human is the only actor who can say a final "no" — through the **ask with reason** dialog.
- Each **ask with reason** opens an **approval request** (`preToolUse-Bash`, one entry per rejected command), keyed by its **tool use id** so the post event can find it; each **allow** writes none.
- A post event (`PostToolUse` or `PostToolUseFailure`) for a **tool use id** means the user said Yes: `postToolUse-Bash` increments the **approval count** of every command in its **approval request**, then closes that request. When the user says No, no post event fires, so no count changes.
- **Approval memory** joins the two hooks of the Bash pipeline: `preToolUse-Bash` opens the **approval request**, `postToolUse-Bash` counts.
- A command whose **approval count** reaches 3 joins the **session allow-list**: from then on, **Solkan** **allow**s it and it no longer appears in **ask with reason**.
- `preToolUse-Monitor` produces **auto-approve** on **allow** and **ask with reason** on **reject**. It writes no **approval request** entry and keeps no **approval count**, so **approval memory** never counts a `Monitor` command. Monitor still honours the **session allow-list**.
- Session state lives in `$CLAUDE_SESSION_DIR/state.json`, the **session allow-list** next to it; both owned by `lib/approval-memory.zsh`. Without a session id, nothing is recorded.

## Flagged ambiguities

- **allow** (**Solkan** decision) vs **auto-approve** (hook output): distinct layers — **Solkan** classifies the command; the hook translates that into a Claude Code response.
- **reject** (**Solkan** decision) vs **ask with reason** (hook output): same distinction — **reject** does not mean "block", it means "escalate to the user".
