## Guidance

- Session scripts follow the slack-writer pattern: `scripts/bin/ai/slack-writer/slack-writer-start` is the reference implementation for `meetup-recap-start`
- Script tests live in `__tests__` directories next to the scripts
- Prose profiles: create `src/*.ini` with overrides only, run `prose-build` (or `yarn run prose-build`) to generate `dist/`
- Lint ZSH with `zsh-lint <filepath>`, test with `bats <filepath>`
- Skill files go in `tools/ai/claude/config/skills/<name>/SKILL.md`
- Edit skill files under the worktree path, never via `~/.claude/skills/` symlinks
- Use `jo` for JSON generation in ZSH scripts
- Use `clipboard-write` for clipboard, never `wl-copy` directly
- The `tick` naming convention means "called at every loop iteration" (not just at the end)

## Discoveries
