## Issue 03 — Rewrite phone-pickup-list

### Standards: notion CLI vs curl directly

```zsh
notion db query "$NOTION_PHONE_DB_ID" \
  --sort 'Date:desc' \
  --limit 50 \
  -f json \
  | jq "$jqFilter"
```

**Problem:** `feedback_notion_api_direct.md` says to use `curl` directly, not a CLI wrapper.
**Reason skipped:** GUIDANCE.md explicitly mandates `notion db query ... -f json | jq` for this command. The memory rule targeted `zsh -i -c 'notion-api-post'`, not the `notion-cli` binary. Project spec overrides general preference.
