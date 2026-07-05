## TLDR

Add `NOTION_PHONE_DB_ID` to the private host config so the phone-pickup functions know which Notion database to query.

## What to build

Add a single export line to the private vorugal host config alongside the existing `NOTION_API_KEY`:

```
export NOTION_PHONE_DB_ID="3937be57b8fa80328fb5f25db51eaf21"
```

This variable is the Notion database ID for the Claude mobile sessions database. It is not a secret but lives in the private config for consistency with how other Notion identifiers are managed.

## Acceptance criteria

- [ ] `NOTION_PHONE_DB_ID` is exported in the private vorugal host config
- [ ] Running `zsh -c 'source ~/.oroshi/private/config/term/zsh/local/vorugal/index.zsh && echo $NOTION_PHONE_DB_ID'` prints the DB ID
- [ ] No changes made to any committed file
