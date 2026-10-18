# Solkan

The command validation layer of the Claude Code hooks: it rewrites commands, then clears or rejects them.

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

**auto allow-list**:
An allow-list of additional commands, for when ralph runs in auto mode.
_Avoid_: ralph allow-list, interpreter list, auto-mode whitelist

## Relationships

- **Solkan** has two phases: **rewrite list** (substitute command names in AST) then allowlist (**allow** or **reject**). The allowlist decision is binary — never partial.
- Each command receives exactly one **Solkan** decision.
- A **rewrite** produces one `updatedInput` JSON field; a command left unchanged produces none.
- The regular **rewrite list** always applies, guard-rails included. For a **single command**, the **token-saving rewrite list** is added after it and overrides it on conflict; for a **compound command**, it is not passed. `preToolUse-Monitor` never passes it, even for a **single command**.
- The **auto allow-list** is added to the regular allow-list only while the ralph session of the session directory runs in `auto` mode.
- The **session allow-list** (see [Approval](./approval.md)) joins the allow-list: a command in it is an **allow**.

## Flagged ambiguities

- **allow** and **reject** are **Solkan** decisions, not hook outputs. The hook outputs are in [Approval](./approval.md).
