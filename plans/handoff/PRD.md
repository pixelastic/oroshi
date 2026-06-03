## Problem Statement

The `handoff` skill (used to spin off a focused side conversation from the current one) has two issues:

1. **Wrong name** — "handoff" is ambiguous and gets mangled by speech-to-text (~20% failure rate). The mental model is "launching a side-quest", not handing off to another agent.

2. **Permission prompt on every use** — The skill writes the handoff document via the Write tool to `/tmp/handoff-XXXXXX.md` (outside the project repo), which triggers a manual approval each time. This friction breaks the flow.

Additionally, one-off scripts created by Claude are written to `~/local/tmp/claude/` (a persistent location), while hook state already lives in `/tmp/oroshi/claude/` (ephemeral, cleared on reboot). These two locations should be unified.

## Solution

1. Rename the `handoff` skill to `sidequest`, rename the companion script `handoff-end` to `sidequest-end`, and update all references.

2. Write sidequest documents to `/tmp/oroshi/claude/sidequests/<slug>.md` — a path inside the already-established `/tmp/oroshi/claude/` tree — and whitelist `Write(/tmp/oroshi/claude/*)` in `settings.json` so no approval prompt appears.

3. Move the one-off scripts convention from `~/local/tmp/claude/` to `/tmp/oroshi/claude/scripts/`, aligning it with the ephemeral tmp tree already used by hooks and sessions. Update `CLAUDE.md` accordingly.

## User Stories

1. As a user, I want to invoke `/sidequest` via speech-to-text reliably, so that the skill is found every time without mis-recognition.
2. As a user, I want to spin off a side conversation about a specific topic without being interrupted by permission prompts, so that the flow is unbroken.
3. As a user, I want the sidequest document filename to reflect the topic (slug), so that I can identify the file at a glance.
4. As a user, I want `sidequest-end` to copy the launch command to my clipboard automatically, so that I can paste it into a terminal immediately.
5. As a user, I want all Claude-generated ephemeral files to live under `/tmp/oroshi/claude/` with domain subfolders, so that they are cleaned up on reboot and easy to locate.
6. As a user, I want CLAUDE.md to point to the correct temp directory for one-off scripts, so that Claude always writes throw-away scripts to the ephemeral location.

## Implementation Decisions

### Module 1 — Skill rename (`handoff` → `sidequest`)

- Rename skill folder from `skills/handoff/` to `skills/sidequest/`.
- Update `name:` field to `sidequest`.
- Update description to reflect the "side-quest" mental model: launching a focused sub-conversation, not handing off to another agent.
- Update the skill instructions:
  - Replace `mktemp -t handoff-XXXXXX.md` with a slug-based path: `<slug>.md` under `/tmp/oroshi/claude/sidequests/`, where `<slug>` is derived by Claude from the conversation content (3–5 words, kebab-case).
  - Replace `handoff-end` call with `sidequest-end`.
  - Add `mkdir -p /tmp/oroshi/claude/sidequests` before writing.

### Module 2 — Script rename (`handoff-end` → `sidequest-end`)

- Create new folder `scripts/bin/ai/sidequest/`.
- Move and rename `scripts/bin/ai/handoff/handoff-end` → `scripts/bin/ai/sidequest/sidequest-end`.
- Update internal comment (the `Called by the /handoff skill` line).
- Remove the old `scripts/bin/ai/handoff/` folder.
- No `sidequest-start` script — the whitelist approach removes the need for it.

### Module 3 — Whitelist settings

- Add `Write(/tmp/oroshi/claude/*)` to the `permissions.allow` array in `~/.claude/settings.json`.
- This covers sidequests, and keeps the door open for future subdirectories under the same tree.

### Module 4 — CLAUDE.md update

- Replace the one-off scripts path in `~/CLAUDE.md`:
  - Before: `/home/tim/local/tmp/claude`
  - After: `/tmp/oroshi/claude/scripts`

### Ephemeral tmp tree — final structure

```
/tmp/oroshi/claude/
├── hooks/       (existing — hook input logging)
├── sessions/    (existing — per-session state)
├── sidequests/  (new — sidequest documents)
└── scripts/     (new — one-off throw-away scripts)
```

## Testing Decisions

No tests for any module in this PRD:
- SKILL.md files are content artifacts, not executable code.
- `sidequest-end` is a trivial 5-line script with no branching logic beyond argument validation; the original `handoff-end` has no tests and this is consistent with that precedent.
- `settings.json` and `CLAUDE.md` are config files — the file itself is the artifact (per project convention: no bats/vitest tests to verify config file content).

## Out of Scope

- **skill-writer worktrees** — `~/local/tmp/claude/skill-writer/` used by the `skill-writer` test harness is not moved. The `skill-writer` skill is outdated and this migration is a separate concern.
- **`sidequest-start` script** — not needed since the whitelist approach eliminates the permission prompt without a helper script.
- **Hook and session path changes** — `/tmp/oroshi/claude/hooks/` and `/tmp/oroshi/claude/sessions/` are already correct; no changes needed.
- **Symlink or backward-compat shim** for the old `handoff` skill name — remove cleanly, no alias.

## Further Notes

The `/tmp/oroshi/claude/` base was chosen (over `/tmp/claude/`) to stay consistent with the existing hook and session directories already in production.

The slug is generated by Claude at runtime from the conversation content — no script involved. Convention: 3–5 words, kebab-case, no date prefix (the topic is more useful than a timestamp for identification).
