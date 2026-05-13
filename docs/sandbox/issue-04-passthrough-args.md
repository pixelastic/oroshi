## What to build

Forward all unrecognised arguments to the underlying `claude` invocation
verbatim. Any argument that is not `--workspace` or `--build` (and is not the
prompt) is passed through unchanged.

This allows the caller to use any Claude CLI flag — `--output-format
stream-json`, `--model`, `--verbose`, etc. — without any sandbox-specific
wrapper.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] `claude-sandbox "prompt" --output-format stream-json` emits JSONL output
- [ ] `claude-sandbox "prompt" --model claude-haiku-4-5-20251001` uses the specified model
- [ ] Unknown flags are forwarded without error
- [ ] `--workspace` and `--build` are never forwarded to Claude
- [ ] Bats test passes

## Blocked by

- issue-02-basic-sandbox
