## Guidance

### Goal

Reduce token consumption in the phone-pickup skill by replacing raw Notion API JSON with compact Claude-readable formats: minimal JSON array for the list, pure Markdown for the read.

### Testing commands

```zsh
# Run all phone-pickup bats tests
bats tools/term/zsh/config/functions/autoload/ai/phone-pickup/__tests__/phone-pickup-list.bats
bats tools/term/zsh/config/functions/autoload/ai/phone-pickup/__tests__/phone-pickup-read.bats

# Lint zsh functions
zsh-lint tools/term/zsh/config/functions/autoload/ai/phone-pickup/phone-pickup-list
zsh-lint tools/term/zsh/config/functions/autoload/ai/phone-pickup/phone-pickup-read

# Lint bats test files
bats-lint tools/term/zsh/config/functions/autoload/ai/phone-pickup/__tests__/phone-pickup-list.bats
bats-lint tools/term/zsh/config/functions/autoload/ai/phone-pickup/__tests__/phone-pickup-read.bats
```

### Key file locations

- `tools/term/zsh/config/functions/autoload/ai/phone-pickup/phone-pickup-list` — list function
- `tools/term/zsh/config/functions/autoload/ai/phone-pickup/phone-pickup-read` — read function
- `tools/term/zsh/config/functions/autoload/notion/api/notion-api` — curl GET helper
- `tools/term/zsh/config/functions/autoload/notion/api/notion-api-post` — curl POST helper
- `tools/term/zsh/config/functions/autoload/notion/api/notion-api-patch` — curl PATCH helper
- `tools/ai/claude/config/skills/phone-pickup/SKILL.md` — skill definition
- `tools/apis/notion-cli/install` — already created; installs notion-cli v0.7.0 via .deb

### Conventions

- `notion-cli` authenticates via `NOTION_TOKEN` env var
- `notion db query <db_id> --sort 'Date:desc' --limit 50 -f json | jq [...]` — list command
- `notion block list <page_id> --md` — read command
- Bats tests use `bats_mock` to stub the `notion` binary, `bats_mock_env` for env vars, `bats_run_zsh` to invoke autoload functions
- All test variables go inside `setup()`, not at file top level
- Use `setopt local_options err_return` (not `set -e`) in autoload functions

### Prior art

- Existing bats tests in `__tests__/phone-pickup-list.bats` and `__tests__/phone-pickup-read.bats` show the mock pattern — rewrite them in place rather than adding alongside

## Discoveries

_Append findings here after each issue._
