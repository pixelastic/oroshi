## TLDR

Add `claude-mcp-add-google-slides`, the server-specific function that encodes the full `claude mcp add` command for Google Slides.

## What to build

Add `claude-mcp-add-google-slides` to
`tools/term/zsh/config/functions/autoload/ai/claude/mcp/`.

The function sources `/home/tim/local/src/google-slides-mcp/.envrc` to load
`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REFRESH_TOKEN` into the current
shell, then calls:

```
claude mcp add --scope user --transport stdio google-slides \
  -e GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID \
  -e GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET \
  -e GOOGLE_REFRESH_TOKEN=$GOOGLE_REFRESH_TOKEN \
  -- node /home/tim/local/src/google-slides-mcp/build/index.js
```

No credentials are stored in oroshi. The `.envrc` is the single source of truth.

After this issue, `claude-mcp-add google-slides` works end-to-end: the dispatcher
(`claude-mcp-add`) finds `claude-mcp-add-google-slides` in PATH and calls it.

No tests — calling the real `claude` CLI would require live credentials and a network
connection; testing would mirror the implementation with no independent signal.

## Acceptance criteria

- [ ] `claude-mcp-add-google-slides` added to the `mcp/` autoload directory
- [ ] sources `.envrc` from the local google-slides-mcp repo before calling `claude mcp add`
- [ ] `claude-mcp-add google-slides` works end-to-end (manual smoke test)
- [ ] `claude-mcp-toggle google-slides` works end-to-end (manual smoke test)
