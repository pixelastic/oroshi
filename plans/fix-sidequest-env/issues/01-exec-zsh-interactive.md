## TLDR

Replace direct `claude` + `zsh` calls with `exec zsh -ic` pattern so Claude inherits interactive env vars.

## What to build

Modify `scripts/bin/kitty/kitty-helper-claude-start` to launch Claude inside an interactive ZSH instead of calling it directly from the non-interactive script context.

The current script runs `claude` then `zsh` sequentially. Replace with:
- Build the claude command string with `${(q)}` quoting for the prompt argument
- `exec zsh -ic "cd <projectRoot> && { claude <args> || true; }; exec zsh"`

This sources `.zshrc` (giving Claude all env vars), runs Claude, then replaces with a fresh interactive ZSH when Claude exits.

Add a comment explaining why the double `exec zsh` is necessary (ZSH has no `--run-then-stay` mode).

Delete `scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats` — the 3 existing tests mock `claude` and `zsh` as executables, but `exec` replaces the process and `.zshenv` rebuilds PATH, making mocks unreachable. No meaningful replacement test is possible.

## Acceptance criteria

- [ ] `kitty-helper-claude-start` uses `exec zsh -ic` pattern
- [ ] Prompt argument is safely quoted with `${(q)}`
- [ ] Defensive `cd` to project root inside the `-c` command
- [ ] `claude || true` ensures non-zero exit doesn't kill the tab
- [ ] Comment explains why double zsh is needed
- [ ] `kitty-helper-claude-start.bats` deleted
- [ ] Manual test: sidequest tab gives Claude access to `NOTION_TOKEN`
- [ ] Manual test: exiting Claude lands in interactive ZSH
