## TLDR

Remove old icon keys and transitional compat code.

## What to build

**icons.jsonc**: remove `tab-attention-stop` and `tab-attention-notification` keys. Only `tab-notification` remains. Run `icons-build`.

**redraw.py**: remove the `# COMPAT:` split-on-colon logic. The parser now expects bare `tabId` lines only. If a line contains `:`, it's an error (or just ignored — match the simpler behavior).

**Tests**: remove any test cases that verified old-format parsing. Update remaining tests to only use bare tabId format.

## Scaffolding Tests

- `dist/icons.json` does not contain `kitty-tab-attention-stop` or `kitty-tab-attention-notification`
- `redraw.py` does not contain `split(":"` or `COMPAT`

## Acceptance criteria

- [ ] No `tab-attention-*` keys in `src/icons.jsonc` or `dist/icons.json`
- [ ] No compat split code in `redraw.py`
- [ ] `python-test` passes
- [ ] `python-lint` passes
- [ ] `icons-build` succeeds
