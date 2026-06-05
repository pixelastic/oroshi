## TLDR

Update `SKILL.md` to enforce 2-word slugs and output a confirmation message.

## What to build

Update `/home/tim/.claude/skills/sidequest/SKILL.md`:
- Change slug derivation from 3-5 words to **2 words max**
- Replace the checklist item about clipboard with a note that the Worktree, Kitty tab, and Claude session are created automatically
- Add agent output instruction: after `sidequest-end` runs, output "Sidequest created in tab `<slug>`"

## Acceptance criteria

- [ ] SKILL.md instructs the agent to derive a slug of at most 2 words
- [ ] SKILL.md checklist no longer mentions clipboard
- [ ] SKILL.md instructs the agent to output "Sidequest created in tab `<slug>`" after running `sidequest-end`
