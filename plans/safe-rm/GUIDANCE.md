## Guidance

### External dependency

This plan depends on the **solkan-rewrite** sidequest (separate repo: `/home/tim/local/www/projects/solkan`). Issues 01–04 can proceed without it. Issue 05 (hook integration) requires solkan's `--rewrite-list-file` feature to be implemented and the solkan package updated in oroshi.

### Testing

- ZSH tests: `bats <filepath>`
- Test files live in `__tests__` directories next to the source
- Prior art for rm tests: `tools/term/zsh/config/functions/autoload/misc/better/__tests__/better-rm.bats`
- Prior art for hook tests: `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`
- Hook tests mock solkan/rtk functions — follow existing patterns

### File locations (relative to repo root)

- New functions: `tools/term/zsh/config/functions/autoload/misc/rm/`
- Hook files: `tools/ai/claude/config/hooks/`
- Aliases: `tools/term/zsh/config/aliases/rm.zsh`
- Allowlist: `tools/ai/claude/config/hooks/allowlist.json`
- Glossary (rm): `tools/term/zsh/config/functions/autoload/misc/rm/__docs/GLOSSARY.md`
- Glossary (hooks): `tools/ai/claude/config/hooks/GLOSSARY.md`

### Conventions

- Use glossary terms: **safe deletion**, **recoverable** (see rm GLOSSARY.md)
- Use glossary terms: **rewrite list**, **allow**, **reject** (see hooks GLOSSARY.md)
- Git plumbing only — `git cat-file -e HEAD:<path>`, `git ls-tree`, `git rev-parse`
- Error messages include bypass hint: "Use /bin/rm to bypass (requires user approval)"
- No partial deletion — if any path fails, refuse all

### Skills

- `/zsh-writer` for ZSH functions
- `/tdd` for test-driven development
- `/js-writer` if touching solkan integration

## Discoveries

(append-only, updated by agents after each issue)
