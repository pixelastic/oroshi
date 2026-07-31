## TLDR

Add a 5th writing principle to the slack-writer skill for conversational warmth, validated by A/B testing the skill output before and after the change.

## What to build

The skill produces messages that are too cold for DMs. Example from a real session:

> **E-commerce site submissions** (external, received by email). I have zero context on these. Do you know anything?

This reads as blunt and robotic. The user would naturally write something softer:

> **E-commerce site submissions** (external, received by email). No idea what these are about... Do you know anything?

Add a 5th bullet point to Step 3's writing principles in `tools/ai/claude/config/skills/slack-writer/SKILL.md`. The principle should cover:
- Conversational tone: softeners are OK ("I think", "not sure", "...")
- Light emoji OK when they soften a blunt statement
- Avoid overly categorical phrasing ("I have zero context" with a hard period)
- Potentially differentiate Reply/DM (warmer) vs Announce/channel (more neutral)

Validation method (TDD-like):
1. Run a sub-agent with the current SKILL.md on a test prompt (the e-commerce portion of the original brain dump)
2. Capture the output as "before"
3. Modify the skill
4. Run a sub-agent with the updated SKILL.md on the same test prompt
5. Capture the output as "after"
6. Present both to the user for comparison
7. Iterate until the user approves

Test prompt to use:
> Write a Slack DM to Chuck. About the e-commerce site submissions we received by email for DevCon: I have no idea what these are, I'd like to know if Chuck knows more or if it's something that's already been discussed.

## Acceptance criteria

- [ ] 5th writing principle added to SKILL.md Step 3
- [ ] "Before" output captured from current skill
- [ ] "After" output captured from modified skill
- [ ] User approved the tone of the "after" version
- [ ] Reply mode produces warmer messages than before
- [ ] Announce mode not negatively affected
