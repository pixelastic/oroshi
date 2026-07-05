## Guidance

### Context

This plan adds the `phone-pickup` skill — a bridge between Claude mobile vocal sessions (saved to Notion) and Claude Code. The feature is read-only: Claude Code lists and reads Notion entries, it never writes back.

### Key locations (relative to repo root)

- New functions: `tools/term/zsh/config/functions/autoload/ai/phone-pickup/`
- New skill: `tools/ai/claude/config/skills/phone-pickup/SKILL.md`
- Private config (not in repo): `~/.oroshi/private/config/term/zsh/local/vorugal/index.zsh`

### Environment variables

- `NOTION_API_KEY` — already set in private config; used by all notion autoload functions
- `NOTION_PHONE_DB_ID` — to be added in issue 01; value: `3937be57b8fa80328fb5f25db51eaf21`

### Notion API

- Base URL: `https://api.notion.com/v1`
- Auth header: `Authorization: Bearer $NOTION_API_KEY`
- Version header: `Notion-Version: 2022-06-28`
- List DB entries: `POST /v1/databases/$NOTION_PHONE_DB_ID/query` with body `{}`
- Read page blocks: `GET /v1/blocks/{page_id}/children`

Use `notion-api-post` for POST calls, `notion-api` for GET calls — do NOT route through `zsh -i -c '...'`.

### Zsh function conventions

- `setopt local_options err_return` at the top of every autoload function
- `local var="$(cmd)"` pattern for capturing output (never split `local`/assignment)
- Flag booleans: `[[ $isXxx == "1" ]]`, not `(( isXxx ))`
- Use `if/then/fi` for 2+ instructions, `&&` only for single-action one-liners

### Testing commands

```zsh
bats tools/term/zsh/config/functions/autoload/ai/phone-pickup/__tests__/<file>.bats
zsh-lint tools/term/zsh/config/functions/autoload/ai/phone-pickup/<function>
bats-lint tools/term/zsh/config/functions/autoload/ai/phone-pickup/__tests__/<file>.bats
```

### Prior art for bats tests

- `tools/term/zsh/config/functions/autoload/ai/claude/__tests__/` — Claude helper tests
- `tools/term/zsh/config/functions/autoload/notion/` — sibling notion function patterns
- Use `bats_mock` to stub collaborators (`notion-api-post`, `notion-api`), `bats_mock_env` to inject env vars
- All test variables go inside `setup()`, never at file top level

### Skill format

Follow `tools/ai/claude/config/skills/sidequest/SKILL.md` — YAML frontmatter with `name` and `description`, then Markdown workflow. Edit only under the worktree path, never via the `~/.claude/skills/` symlink.

### Issue 01 — HITL

Issue 01 requires manual editing of the private submodule. The ralph agent should skip it and start with 02 or 03.

## Discoveries

### Issue 04 — phone-pickup skill

- `skill-writer`'s `skill-template.md` format (Goal/Exit criterion per step, Common Rationalizations table) is for enforcement skills only — simple workflow skills like `phone-pickup` follow the lighter `sidequest` pattern instead.
- Bats `set -e` semantics: `grep -qv` returning 1 (no bad lines — success) causes bats to fail the test. Use `|| true` and then `[[ -z "$var" ]]` instead of relying on `grep -qv`'s exit code directly.
- Words like "created" in field descriptions will trigger a read-only grep guard; use neutral synonyms ("added") to avoid false positives.
