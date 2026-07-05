## Issue 02 — phone-pickup-list

### Missing NOTION_API_KEY guard

```zsh
curl \
  --silent \
  --request POST \
  "https://api.notion.com/v1/databases/${NOTION_PHONE_DB_ID}/query" \
  --header 'Authorization: Bearer '"$NOTION_API_KEY"'' \
```

**Problem:** No guard on `NOTION_API_KEY`; unset would silently send an empty bearer token.
**Reason skipped:** Out of scope. The spec only requires a guard for `NOTION_PHONE_DB_ID`. `NOTION_API_KEY` is a global prerequisite for all notion functions — none of the sibling functions guard it either.

### Spec agent: bats_mock pattern flagged as contradictory

```bats
curl() {
  echo "$*" > "$BATS_TMP_DIR/curl.log"
  echo '{"object":"list"}'
}
bats_mock curl
```

**Problem:** Spec agent claimed defining a function then calling `bats_mock` was contradictory.
**Reason skipped:** Incorrect analysis. Per `testing.md` and helper source, this is the canonical pattern: define the function body, then `bats_mock` injects it into the subprocess via the mock file.

## Issue 03 — phone-pickup-read

### bats_mock_env inside @test blocks

```bats
bats_mock_env "NOTION_API_KEY" "test-api-key"
```

**Problem:** Reviewer flagged `bats_mock_env` calls inside `@test` blocks rather than `setup()`.
**Reason skipped:** Memory rule "all test vars go inside setup()" refers to file-level variables. Per-test env overrides with different values per test belong inside the test body. Prior art in `phone-pickup-list.bats` uses the same pattern.

### Header inline annotation

```zsh
# $ phone-pickup-read <page_id>
```

**Problem:** Reviewer noted the usage line lacks a trailing inline annotation explaining `<page_id>`.
**Reason skipped:** Judgement call; no other phone-pickup functions include argument annotations in usage comments. Out of scope for this issue.
