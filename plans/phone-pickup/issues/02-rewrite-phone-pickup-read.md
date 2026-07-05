## TLDR

Rewrite `phone-pickup-read` to output pure Markdown via `notion block list --md`.

## What to build

Replace the `notion-api` call with a `notion block list <page_id> --md` call. The function takes a page ID as its only argument and writes the Markdown content of that page to stdout. The missing-argument guard is preserved.

The existing tests assert on implementation details (which endpoint was called, that raw JSON passes through unchanged) — both will be false after this rewrite. Replace them with behavioral tests that mock the `notion` binary and verify output shape.

## Behavioral Tests

**Happy path**
- outputs the Markdown returned by `notion` when given a valid page ID

**Guard**
- exits non-zero when called without a page ID

## Acceptance criteria

- [ ] `phone-pickup-read <page_id>` outputs Markdown to stdout
- [ ] `phone-pickup-read` (no args) exits non-zero
- [ ] Old tests removed; new behavioral tests pass
- [ ] `bats-lint` passes on the test file
- [ ] `zsh-lint` passes on the function file
