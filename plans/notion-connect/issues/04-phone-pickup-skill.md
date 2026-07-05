## TLDR

Create the `phone-pickup` skill that instructs Claude to retrieve a mobile discussion from Notion by description.

## What to build

Create the `phone-pickup` skill file in the skills directory, following the established `SKILL.md` + YAML frontmatter format used by sidequest, grill-me, and other skills.

The skill instructs Claude to:

1. Call `phone-pickup-list` to retrieve all entries from the Notion database as raw JSON
2. Parse the JSON to extract each entry's title, date, and tags
3. Match the user's description against those fields to identify the best candidate; if the match is ambiguous, present the shortlist and ask the user to choose
4. Call `phone-pickup-read {page_id}` with the identified page ID to fetch the page's block content
5. Parse and present the content to the user, ready to continue the conversation

The skill is read-only: it never creates, updates, or deletes Notion pages.

The frontmatter description should make the skill triggerable by natural phrases like "phone pickup", "récupère la discussion du téléphone", "pick up the conversation from the phone".

## Acceptance criteria

- [ ] Skill file exists in the skills directory with correct YAML frontmatter (`name`, `description`)
- [ ] Skill instructs Claude to call `phone-pickup-list` then `phone-pickup-read`
- [ ] Skill handles the ambiguous-match case (present candidates, ask user to pick)
- [ ] Skill is read-only (no write instructions)
- [ ] Skill is added to the worktree, not to the symlinked `~/.claude/skills/` path
