# Glossary — preToolUse Bash Hook

## Decision layers

There are 3 distinct decision layers. Each has its own vocabulary.

### Layer 1 — Solkan

Solkan makes a **binary** decision about a command.

| Term | Meaning |
|------|---------|
| **allow** | Command is in the allowlist — safe to execute without user input |
| **reject** | Command is not in the allowlist |

Solkan can say **yes** or **no**. Never "maybe".

### Layer 2 — RTK

RTK makes a **binary** decision about whether to optimize a command.

| Term | Meaning |
|------|---------|
| **rewrite** | RTK has an equivalent — transforms `git status` into `rtk git status` |
| **ignore** | RTK has no equivalent — command is left unchanged |

Determined via `rtk rewrite <cmd>`: exit 0 = rewrite, exit 1 = ignore.

### Layer 3 — Hook (`preToolUse-Bash`)

The hook interprets Solkan's decision and produces an output for Claude Code.

| Term | Solkan response | Meaning |
|------| --------------- | ---------|
| **auto-approve** | **allow** | Command executes immediately, no user interaction |
| **ask** | **reject** | Claude's permission dialog appears — the user decides yes or no |

The hook can say **yes** or **maybe**.

The human is the only actor who can say a final "no" — and only in the `ask` path.

If RTK **rewrites**, the **updatedInput** JSON field is set he rewritten command.

---

### The 4 cases

| Solkan | RTK | Hook output |
|--------|-----|-------------|
| allow | rewrite | auto-approve + updatedInput |
| allow | ignore | auto-approve (no updatedInput) |
| reject | rewrite | ask + updatedInput |
| reject | ignore | ask (no updatedInput) |

---

### Execution order

Solkan runs **first**, RTK runs **second**.
RTK runs regardless of Solkan's decision.
