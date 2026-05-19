## Execution order

0001 → start here, no blockers
0002 → needs 0001
0003 → needs 0002

## Guidance

- The ralph script lives in `scripts/bin/claude/ralph` — it has a shebang and uses `set -e`
- The ralph skill lives in `config/ai/claude/claudecode/skills/ralph/SKILL.md`
- `ralph-end` is a new script in `scripts/bin/claude/ralph-end` (same domain as `ralph`)
- Use `zsh-writer` skill when writing or modifying any ZSH script
- Use `zparseopts -E -D` for flag parsing (not manual `$1` shifting)
- Bats tests live in `scripts/bin/__tests__/` — see `git-worktree-project.bats` and `oroshi-prompt-path-worktree.bats` as prior art for test structure (temp git repos, stubbed commands via PATH prepend)
- Stub external commands by creating executable files in a temp `bin/` dir prepended to PATH in the bats test setup
- `audio-play-oroshi ralph-timeout.mp3` is the sound call — stub it to write to a capture file in tests
- `.ralph-done` and `.ralph-prd-done` are written inside `<dir>` (the PRD directory argument), not the git root
- The `--max` flag (not `--iterations`) is the user-facing API

---
## Log (append below when an issue is completed)
