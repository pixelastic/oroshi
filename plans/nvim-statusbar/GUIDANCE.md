## Guidance

### Domain glossary

Terms from `tools/term/zsh/config/functions/autoload/project/CONTEXT.md` apply throughout:
- **Project Badge** — the colored block with icon + project name (always present)
- **Worktree Badge** — the orange block with branch name (present only inside a linked worktree)
- **Context Badge** — the combination: Project Badge + optional Worktree Badge
- **Context Root** — worktree root when inside a linked worktree; project root otherwise

All Lua variable and function names must use this vocabulary (`projectBadge`, `worktreeBadge`, `getContextBadge`, `contextRoot`).

### Reference implementation

The zsh `context-badge` and `context-root` functions are the canonical reference for badge rendering and filepath root logic. When in doubt, mirror their behavior exactly.

- `context-badge`: `tools/term/zsh/config/functions/autoload/project/context-badge`
- `context-root`: `tools/term/zsh/config/functions/autoload/project/context-root`

### Shell calls from Lua

The statusline calls zsh functions via `vim.fn.systemlist()`. Follow the existing pattern:
```lua
vim.fn.systemlist("some-zsh-function " .. vim.fn.shellescape(arg))[1]
```
New calls needed: `git-worktree-name <filepath>` and `context-root <filepath>`.

### Caching

Per-buffer data is cached in `vim.b.statuslineFileData`. All resolved values (projectBadge, worktreeBadge, contextRoot, file) go into this cache. The cache is already invalidated on `BufFilePost`.

### Colors

Worktree Badge colors: `bg = "ORANGE_7"`, `fg = "ORANGE_1"`. Declared in `O.colors.statusline` in the colorscheme ui file, alongside all other statusline color entries.

### Testing

No automated tests. Verify visually in NeoVim across these four scenarios:
1. Regular file inside a project (no worktree)
2. File inside a linked worktree
3. NvimTree buffer
4. Special buffer (`:checkhealth`, CodeCompanion, or kitty pager)

### No Lua test framework

Do not write bats wrappers for headless nvim. Skip the test phase entirely for Lua changes.

## Discoveries

_Append-only. Each completed issue adds a subsection here._
