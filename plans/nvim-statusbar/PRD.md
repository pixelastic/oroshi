## Problem Statement

The NeoVim statusline displays a Project Badge and a simplified filepath, but it is missing the Worktree Badge that appears in the terminal prompt whenever the user is inside a linked worktree. The result is that the statusline gives an incomplete picture of the current Context: you can see which project you're in, but not which worktree branch. Additionally, the filepath simplification is broken inside worktrees because it strips the project root path, which doesn't match the worktree directory — leaving an un-shortened absolute path on screen. Finally, the mode badge (NORMAL / INSERT / VISUAL…) takes up unnecessary horizontal space.

## Solution

Align the NeoVim statusline's left section with the terminal prompt's Context Badge logic:

1. **Context Badge in the statusline** — render a Project Badge always, followed by a Worktree Badge (in orange) when inside a linked worktree, using the same colors and powerline arrow transitions as the terminal prompt's `context-badge` function.
2. **Fix filepath root** — compute the simplified filepath relative to the Context Root (worktree root when in a worktree, project root otherwise), mirroring how `context-root` works in zsh.
3. **Shrink mode badge** — replace full words (`NORMAL`, `INSERT`, …) with single letters (` N `, ` I `, …) to reclaim horizontal space.

## User Stories

1. As a NeoVim user working in a linked worktree, I want to see the Worktree Badge (branch name in orange) in the statusline, so that I always know which branch I am on without looking at the terminal prompt.
2. As a NeoVim user not in a worktree, I want the statusline to show only the Project Badge (no Worktree Badge), so that the display is clean and uncluttered.
3. As a NeoVim user, I want the powerline arrow after the Project Badge to transition into the Worktree Badge background color when a worktree is active, so that the badges visually connect the way they do in the terminal prompt.
4. As a NeoVim user, I want the powerline arrow after the Project Badge to have a transparent background when no worktree is active, so that the badge ends cleanly against the statusline background.
5. As a NeoVim user working in a linked worktree, I want the displayed filepath to be relative to the worktree root, so that it is short and meaningful rather than an unstripped absolute path.
6. As a NeoVim user not in a worktree, I want the displayed filepath to be relative to the project root, so that it stays consistent with the rest of the project display.
7. As a NeoVim user, I want the mode badge to show ` N `, ` I `, ` V `, ` S `, ` C ` instead of full words, so that horizontal space is freed up for the Context Badge and filepath.
8. As a NeoVim user, I want the Worktree Badge colors to match the terminal prompt (orange background, lighter orange text), so that the visual language is consistent across prompt and statusline.

## Implementation Decisions

### Naming — align with domain glossary

All new Lua variables and functions use the terminology from the project's domain glossary (`CONTEXT.md`):
- **Project Badge** → `projectBadge` — the colored block showing icon + project name
- **Worktree Badge** → `worktreeBadge` — the orange block showing the branch name; absent when not in a worktree
- **Context Badge** — the combination of Project Badge + optional Worktree Badge; resolved by a new `getContextBadge()` function in `O_STATUSLINE`
- **Context Root** — the root used for filepath relativization; worktree root in worktrees, project root otherwise

### New function: `getContextBadge(filepath)`

Replaces the inline project-badge logic currently embedded in `getFileData()`. Responsibilities:
- Resolves `projectBadge` (icon, name, colors) from project data — same as today
- Resolves `worktreeName` via shell call to `git-worktree-name <filepath>`
- Returns `{ projectBadge, worktreeBadge }` where `worktreeBadge` is `nil` when not in a worktree

### Filepath root fix

Replace the current `projectData.path` stripping with a shell call to `context-root <filepath>`. This returns the worktree root inside a worktree, and the project root otherwise — matching `context-root`'s zsh behavior exactly.

### Rendering in `main()`

The left section rendering order becomes:
1. Mode badge (single letter, e.g. ` N `)
2. Separator arrow: `fg = modeBg`, `bg = projectBadge.hl.bg`
3. Project Badge
4. **If worktree:** separator arrow `fg = projectBadge.hl.bg`, `bg = worktreeBadge.hl.bg` → Worktree Badge → separator arrow `fg = worktreeBadge.hl.bg`
5. **If no worktree:** separator arrow `fg = projectBadge.hl.bg` (no bg — transparent)
6. Filepath

### Worktree Badge colors

Declared in `O.colors.statusline` alongside all other statusline color entries:

```
worktree = { bg = "ORANGE_7", fg = "ORANGE_1" }
```

These match `COLOR_ORANGE_7` (ANSI 130) and `COLOR_ORANGE_1` (ANSI 208) used in the zsh `context-badge` function.

### Caching

`worktreeName` and `contextRoot` are resolved once per buffer and stored in the existing `vim.b.statuslineFileData` cache alongside `projectBadge`, `worktreeBadge`, and `file`. The cache is already invalidated on `BufFilePost` — no change needed there.

### Mode badge strings

| Before | After |
|--------|-------|
| ` NORMAL ` | ` N ` |
| ` INSERT ` | ` I ` |
| ` VISUAL ` | ` V ` |
| ` SEARCH ` | ` S ` |
| ` COMMAND ` | ` C ` |

## Testing Decisions

No tests are written for this feature. There is no Lua test framework in this project; bats wrappers for headless nvim are explicitly out of scope. The changes are verified by visual inspection in NeoVim across four scenarios: normal project (no worktree), linked worktree, special buffers (healthcheck, CodeCompanion, kitty pager), and NvimTree.

## Out of Scope

- Adding a worktree badge to special buffer displays (healthcheck, CodeCompanion, kitty pager) — these have fixed content and are unrelated to the filesystem context.
- Changing the right-hand side of the statusline (LSP, Copilot, filetype, encoding, etc.).
- Any changes to the zsh `context-badge`, `context-root`, or related shell functions.
- Async resolution of `git-worktree-name` or `context-root` — the existing synchronous `vim.fn.systemlist` pattern is used, consistent with how `project-name` and `simplify-path` are already called.
