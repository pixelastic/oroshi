# Glossary

## Global Vocabulary

Terms that apply across all modules in this repository.

**Reload**:
Re-read source data from disk and rebuild in-memory state. A heavyweight operation that often triggers a Redraw.
Examples: `colors-reload`, `oroshi-reload-fpath`, `kitty-reload`
_Avoid_: refresh

**Redraw**:
Update the visual display from existing in-memory state, without touching the disk. A lightweight operation.
Examples: `prompt-redraw`, `kitty-redraw`
_Avoid_: refresh, repaint

> "refresh" conflates both meanings and is banned — always use the precise term.

## Modules

- [BATS Helper](tools/term/bats/GLOSSARY.md) — Worktree-aware, Deep Mocking, Root Override — the 3 guarantees of the test helper
- [preToolUse Bash Hook](tools/ai/claude/config/hooks/GLOSSARY.md) — Solkan/RTK decision layers, auto-approve vs ask-user, the 4 hook cases
- [Git Worktree Toolbox](tools/term/zsh/config/functions/autoload/git/worktree/GLOSSARY.md) — Worktrees, branch slugs, worktrees store, dirty state, and design decisions
- [Project Display](tools/term/zsh/config/functions/autoload/project/GLOSSARY.md) — Projects, Contexts, Context Badges, Project Badges, Worktree Badges
- [FZF](scripts/bin/fzf/__docs/GLOSSARY.md) — FZF Scripts, Lifecycle Functions, FZF Helpers, Neovim API, Legacy FZF
- [FZF ctrl-r](scripts/bin/fzf/__docs/GLOSSARY-ctrl-r.md) — Eager/Lazy colorization strategies, History diff, Cache, Mutex
- [Kitty Tab Bar](tools/term/kitty/config/GLOSSARY.md) — Tab Bar, Statusbar, Redraw, Reload, Reload Beacon, Attention
