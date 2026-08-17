## Guidance

- Testing: `bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-solkan.bats`
- Linting: `bats-lint tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-solkan.bats` and `zsh-lint tools/ai/claude/config/hooks/preToolUse-Bash-solkan.zsh`
- Hook files: `tools/ai/claude/config/hooks/`
- Test files: `tools/ai/claude/config/hooks/__tests__/`
- The wrapper `preToolUse-Bash-solkan.zsh` is sourced (not executed) — no shebang, uses `hookDir` from caller scope
- Tests mock via the guard `whence preToolUse-Bash-solkan > /dev/null && return 0` — define the function before sourcing to override
- `git-directory-root` is a zsh autoload function, already in the global allow-list
- Solkan multi-file support is a separate sidequest (`solkan-multi-file`) — issue 02 depends on it being merged first
- Use `/zsh-writer` skill for hook implementation, `/tdd` for tests

## Discoveries

### Issue 02 — Local allow and rewrite lists
- Solkan multi-file support (multiple `--allow-list-file` / `--rewrite-list-file` flags) is available via portal link to local dev copy. The hook passes multiple flags directly — no jq merge needed.
