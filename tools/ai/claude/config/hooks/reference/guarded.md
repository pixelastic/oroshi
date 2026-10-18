# Guarded commands

Commands that check what they are asked to do, and how a refusal reaches Claude.

## Language

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

## Relationships

- A **guarded** command comes from the **rewrite list** (see [Solkan](./solkan.md)).
- A **guarded refusal** is not a **reject**: **Solkan** already allowed the command, and the **guarded** command itself declined to act.
- A **guarded refusal** has one or more **refusal lines**; each **refusal line** starts with the **refusal prefix**.
- `lib/guarded.zsh` owns the **refusal prefix** and the **report**; the hook decides when to **report**.
