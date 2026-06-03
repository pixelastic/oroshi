## Problem Statement

The Legacy FZF system is spread across 119 autoloaded ZSH functions with 4-5 levels of indirection,
making it hard to understand, maintain, and extend. Adding features (simplified path display for
long paths, custom Ctrl-P pickers per command) requires modifying deeply fragmented code with no
tests. Long file paths overflow the FZF display and truncated segments become unsearchable because
display and search are coupled. The system has no consistent interface between ZSH and Neovim,
forcing Neovim to call internal sub-functions rather than a stable public API.

## Solution

Replace the Legacy FZF system with a set of FZF Scripts — executable `#!/bin/zsh` scripts in
`scripts/bin/fzf/`, one per keybinding or domain. Each FZF Script contains the same four Lifecycle
Functions (`fzf-source`, `fzf-options`, `fzf-postprocess`, `fzf-main`) and exposes a Neovim API
(`--source`, `--options`, `--postprocess` flags) so Neovim can call individual stages without
knowing the internal structure. Shared logic lives in FZF Helpers — `.zsh` files sourced at the
top of each script. Migration follows the strangler fig pattern: new FZF Scripts are merged into
main alongside the Legacy FZF system; once all scripts are migrated, legacy autoloads are removed.

## User Stories

1. As a developer, I want to open a file from my project by pressing Ctrl-P, so that I can navigate quickly without leaving the terminal.
2. As a developer, I want to search on any segment of a long file path even if it is truncated in the display, so that deep paths remain discoverable.
3. As a developer, I want to open a file from the current directory by pressing Ctrl-Shift-P, so that I can narrow the search scope when needed.
4. As a developer, I want to grep across my project with Ctrl-G, so that I can find usages and definitions quickly.
5. As a developer, I want to grep in the current directory with Ctrl-Shift-G, so that I can scope searches to a subdirectory.
6. As a developer, I want to jump to a project directory with Ctrl-O, so that I can navigate my project structure without typing paths.
7. As a developer, I want to jump to a subdirectory with Ctrl-Shift-O, so that I can navigate locally within my current context.
8. As a developer, I want to search my shell history with Ctrl-R, so that I can reuse previous commands quickly.
9. As a developer, I want to search available commands and binaries with Ctrl-B, so that I can discover and invoke tools without memorising their names.
10. As a developer, I want to search apt packages when running `apt-install` without arguments, so that I can find package names without a separate search step.
11. As a developer, I want to search Docker Hub images when running `docker-image-pull` without arguments, so that I can find image names interactively.
12. As a developer, I want to browse a file's git history via the `vfh` workflow, so that I can inspect previous versions of a file.
13. As a developer, I want Ctrl-P in Neovim to use the same source and options as Ctrl-P in ZSH, so that search behaviour is consistent between editor and terminal.
14. As a developer, I want Ctrl-G in Neovim to use the same regexp source and options as Ctrl-G in ZSH, so that grep behaviour is consistent.
15. As a developer, I want to open any FZF Script and immediately see its full implementation in one place, so that I do not have to trace through multiple indirection layers.
16. As a developer, I want FZF Scripts to be callable from Kitty, Neovim, and ZSH without requiring ZSH autoload setup, so that integration is straightforward.
17. As a developer, I want the Legacy FZF system to remain functional during migration, so that no existing workflow breaks while new scripts are being introduced.
18. As a developer, I want unused FZF keybindings and dead code removed, so that the codebase does not accumulate maintenance burden from features nobody uses.

## Implementation Decisions

### Architecture

- Each FZF Script is a `#!/bin/zsh` executable in `scripts/bin/fzf/`, named after its keybinding (`ctrl-p`, `ctrl-g`, ...) or its domain (`apt-packages`, `docker-images`, `git-file-history`).
- Every FZF Script defines exactly four Lifecycle Functions: `fzf-source`, `fzf-options`, `fzf-postprocess`, `fzf-main`.
- `fzf-main` assembles the pipeline: `fzf-source | fzf $(fzf-options) | fzf-postprocess`
- `fzf-postprocess` always receives input via stdin (never via argument), enabling clean piping.
- A `case "$1"` dispatch at the bottom of each script routes `--source`, `--options`, `--postprocess` to the corresponding Lifecycle Function, and no-argument to `fzf-main`.

### Neovim API

- Neovim calls FZF Scripts using the flag interface: `ctrl-p --source`, `ctrl-p --options`, `ctrl-p --postprocess`.
- `disk.lua` is updated to call the new FZF Scripts instead of Legacy FZF autoloads.
- Neovim's `sinklist` callback calls `ctrl-p --postprocess` to clean the selection, then performs editor-specific actions (tab drop, line jump). The sinklist is NOT the same as `fzf-postprocess` — it wraps it.
- The Ctrl-T duplicate binding in Neovim is removed; only Ctrl-Shift-P remains.

### FZF Helpers

- Shared functions live in `scripts/bin/fzf/helpers/`, split by domain: `fs.zsh`, `git.zsh`, `prompt.zsh`, `options.zsh`.
- Each file carries a `.zsh` extension to signal it is sourced, not executed.
- FZF Scripts source only the helpers they need at the top of the file.
- Helper functions are called directly (no subshell) to avoid subprocess overhead.

### Migration Strategy (Strangler Fig)

- New FZF Scripts are developed in the `fzf-refactor` branch and merged into `main` one at a time.
- Migration order starts with the simplest scripts (`ctrl-r`) and progresses to the most complex (`ctrl-p`, `ctrl-g`).
- For `ctrl-p`: the simplified-path display logic from the `skills-reference` worktree is backported at migration time.
- For completion/picker features: relevant parts of the `completion-ctrlp` worktree are backported after the new system is complete.
- Both worktrees (`skills-reference`, `completion-ctrlp`) are completed but never merged to main; they serve as reference implementations only.
- Legacy autoloads are deleted per-domain as each FZF Script is merged and verified.

### Legacy Cleanup

Two cleanup phases:

**Immediate deletions** (dead code, no replacement needed):
- Ctrl-T ZSH keybinding widget (duplicate of Ctrl-Shift-P)
- Ctrl-H ZSH keybinding widget (git commits, never used)
- Ctrl-J ZSH keybinding widget (frequent directories, broken, never used)
- `vfh` alias (git file history, replaced by `git-file-history` FZF Script)
- `vim-fzf-project-files` script (superseded by Legacy FZF autoloads)
- `vim-fzf-git-file-history` script (superseded by Legacy FZF autoloads)

**Post-migration deletions**: Legacy FZF autoload functions are deleted domain by domain as their corresponding FZF Script is merged and verified.

**Deferred evaluation at cleanup end**: `ctrl-shift-i` (Claude sessions) remains in legacy until the end of migration; at that point it is either migrated or removed based on whether a good implementation can be found.

### Glossary

All terms follow `scripts/bin/fzf/GLOSSARY.md`.

## Testing Decisions

A good test exercises the external behaviour of a Lifecycle Function in isolation — given a specific filesystem state or input, it produces the expected output. Tests do not test implementation details (which commands are run internally) and do not require a running interactive FZF terminal.

**Tested: `fzf-source` for each FZF Script**
- Given a known directory structure, `--source` outputs the expected candidate list.
- Prior art: existing BATS tests for `fzf-claude-sessions-source-no-query` and `fzf-prompt-directory` in `tools/term/zsh/config/functions/autoload/fzf/`.

**Tested: `fzf-postprocess` for each FZF Script**
- Given a known raw FZF selection on stdin, `--postprocess` outputs the expected clean result.
- Covers path extraction, file:line parsing, deduplication where applicable.
- Prior art: same BATS test suite.

**Not tested:**
- `fzf-main` — requires interactive terminal with fzf; not testable in isolation.
- `fzf-options` — returns static flag strings; no meaningful assertions beyond "it runs".
- FZF Helpers — tested indirectly via the FZF Script tests that source them.

Test files live in `__tests__/` subdirectories adjacent to the scripts they test, following existing project conventions.

## Out of Scope

- Switching from `fzf.vim` to `fzf-lua` in Neovim (separate decision, no architectural benefit for this refactor).
- Improving the Claude sessions search (Ctrl-Shift-I) — deferred to post-migration evaluation.
- Adding a project-jump picker to replace Ctrl-J — deferred to post-migration evaluation.
- The `completion-ctrlp` features (compdef registrations, Shift-Tab via fzf-tab, custom Ctrl-P pickers per command) — backported after new system is complete, not part of this PRD.
- The simplified-path display for `ctrl-p` (`skills-reference` work) — backported when `ctrl-p` is migrated, tracked within that migration issue.

## Further Notes

- The `fzf-refactor` worktree is the development environment for this work. Each completed FZF Script is merged to `main` independently, maintaining a working system throughout.
- The `_shared` naming was rejected in favour of the `helpers/` directory with `.zsh`-suffixed files.
- The term "postprocess" is kept (not "sink" or "sinklist") — sinklist is a Neovim concept that wraps postprocess; they are distinct layers.
