## Guidance

### External dependency

This plan depends on the **solkan-rewrite** sidequest (separate repo: `/home/tim/local/www/projects/solkan`). Issues 01–04 can proceed without it. Issue 05 (hook integration) requires solkan's `--rewrite-list-file` feature to be implemented and the solkan package updated in oroshi.

### Testing

- ZSH tests: `bats <filepath>`
- Test files live in `__tests__` directories next to the source
- Prior art for rm tests: `tools/term/zsh/config/functions/autoload/misc/rm/__tests__/rm-for-cli.bats`
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

### Issue 01 — rm-for-claude files
- ZSH ties `$path` to `$PATH` — never use `path` as a loop variable name (clobbers system PATH)
- `local` always returns 0 in ZSH — can't use `local var="$(cmd)" || guard`; check the value instead
- `bats_tmp_dir` inside a test wipes `$BATS_TMP_DIR` (and the git dir inside it); create subdirs of existing `$BATS_TMP_DIR` instead

### Issue 02 — rm-for-claude dirs
- `git ls-tree` has no `--recursive` long-form — only `-r` works; treat like `find -type` exception
- Don't `git init` inside the worktree during debugging — it confuses zshenv and breaks all autoloaded functions
