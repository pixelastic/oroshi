## TLDR

Rename the `handoff` skill to `sidequest` and update its instructions to use the whitelisted ephemeral path.

## What to build

Rename and rewrite the skill so that invoking `/sidequest` (with an optional topic hint) produces a focused handoff document without any permission prompt:

1. Rename skill folder from `skills/handoff/` to `skills/sidequest/`
2. Update `name:` to `sidequest`
3. Update description to reflect the side-quest mental model: launching a focused sub-conversation from the current one, not handing off to another agent
4. Update instructions:
   - Slug: Claude derives a 3–5 word kebab-case slug from the conversation content (or from the argument if provided)
   - Path: write the document to `/tmp/oroshi/claude/sidequests/<slug>.md`, creating the directory with `mkdir -p` if needed
   - End call: `sidequest-end <path>` (was `handoff-end`)
5. Keep the rest of the document-writing instructions intact (no duplication of existing artifacts, suggest skills for the next session, tailor to argument if provided)

## Acceptance criteria

- [ ] `skills/sidequest/SKILL.md` exists with `name: sidequest`
- [ ] `skills/handoff/` directory is deleted
- [ ] Skill description reflects "side-quest" mental model
- [ ] Instructions reference `/tmp/oroshi/claude/sidequests/<slug>.md` (not `mktemp`)
- [ ] Instructions call `sidequest-end` (not `handoff-end`)
- [ ] `/sidequest` can be invoked via speech-to-text or typed without ambiguity
