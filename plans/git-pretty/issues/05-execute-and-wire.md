## TLDR

Wire it all together: accept args, call git-branch-push, pipe stderr through parser into TUI.

## What to build

The `main.go` entry point that:

1. Accepts the same arguments as `git-branch-push` (branch, remote, flags like --force, --repo)
2. Resolves branch/remote names (by calling `bin-zsh git-branch-current` / `bin-zsh git-remote-current` if not provided) — needed for the summary and theme color resolution
3. Loads the theme (colors, icons, branch/remote colors)
4. Spawns `bin-zsh git-branch-push [args] --progress` as a subprocess
5. Reads stderr line by line (splitting on `\r` and `\n`)
6. Feeds each line through the parser
7. Sends parsed events to the bubbletea TUI as messages
8. On subprocess exit: sends a "done" message with exit code
9. On error (non-zero exit): prints raw stderr and exits with same code
10. On "up to date": prints brief confirmation and exits 0

At this stage, the success summary is a placeholder — the styled summary comes in issue 06.

## Acceptance criteria

- [ ] Binary accepts same args as git-branch-push
- [ ] Calls git-branch-push via bin-zsh with --progress
- [ ] Stderr is captured and parsed in real-time
- [ ] Progress bar updates live during push
- [ ] Errors are shown unfiltered and exit code is preserved
- [ ] "Everything up-to-date" shows brief confirmation
- [ ] Ctrl+C kills both the TUI and the git subprocess
