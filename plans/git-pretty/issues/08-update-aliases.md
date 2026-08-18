## TLDR

Update all push-related ZSH aliases to use git-branch-push-pretty.

## What to build

In `tools/term/zsh/config/aliases/git/branch.zsh`, update all aliases that currently point to `git-branch-push` to point to `git-branch-push-pretty` instead.

This includes at minimum: `vbps`, `vbpsf`, `vbpsn`, and any other push variants.

The underlying `git-branch-push` function remains unchanged and still usable directly for scripts or when pretty output is not desired.

## Acceptance criteria

- [ ] `vbps` calls `git-branch-push-pretty`
- [ ] `vbpsf` calls `git-branch-push-pretty --force-with-lease`
- [ ] All other push aliases updated similarly
- [ ] `git-branch-push` still works directly (unchanged)
