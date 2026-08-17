## TLDR

Rename global `allowlist.json` → `allow-list.json` and `rewrite.json` → `rewrite-list.json` for naming consistency with solkan flags.

## What to build

Rename the two global files in `tools/ai/claude/config/hooks/`:
- `allowlist.json` → `allow-list.json`
- `rewrite.json` → `rewrite-list.json`

Update all references to these filenames:
- `preToolUse-Bash-solkan.zsh` — the wrapper that passes file paths to solkan
- `__tests__/preToolUse-Bash-solkan.bats` — if it references filenames directly
- `GLOSSARY.md` — if it mentions filenames

## Scaffolding Tests

After rename, all existing tests in `__tests__/preToolUse-Bash-solkan.bats` must still pass. The tests use `hookDir` to resolve files, so they should work once the wrapper references the new names.

## Acceptance criteria

- [ ] `allowlist.json` renamed to `allow-list.json`
- [ ] `rewrite.json` renamed to `rewrite-list.json`
- [ ] `preToolUse-Bash-solkan.zsh` references updated
- [ ] All existing bats tests pass
- [ ] No other files reference the old filenames
