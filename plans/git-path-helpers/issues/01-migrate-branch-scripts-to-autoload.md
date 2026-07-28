## TLDR

Move 12 `scripts/bin/git/branch/` scripts to autoload functions.

## What to build

Migrate all 12 scripts from `scripts/bin/git/branch/` to `tools/term/zsh/config/functions/autoload/git/branch/`:

- `git-branch-copy`
- `git-branch-create`
- `git-branch-merge`
- `git-branch-prune`
- `git-branch-pull`
- `git-branch-push`
- `git-branch-rebase`
- `git-branch-rebase-interactive`
- `git-branch-remove`
- `git-branch-remove-remote`
- `git-branch-squash`
- `git-branch-switch`

For each file:
1. Remove the `#!/usr/bin/env zsh` shebang
2. Replace `set -e` with `setopt local_options err_return`
3. Move to the autoload directory
4. Delete the original script

`git-branch-push` has a custom arg parser (loop splitting flags/positionals into separate arrays). Leave it as-is for now — the zparseopts conversion happens in issue 02 when `--repo` is added.

## Scaffolding Tests

Verify structural transformation:
- Each of the 12 files exists in `tools/term/zsh/config/functions/autoload/git/branch/`
- None of the 12 files exist in `scripts/bin/git/branch/`
- No file in the autoload dir contains a shebang line
- No file in the autoload dir contains `set -e`

## Acceptance criteria

- [ ] All 12 files moved to autoload directory
- [ ] Shebangs removed from all 12 files
- [ ] `set -e` replaced with `setopt local_options err_return` in all 12
- [ ] Old scripts deleted from `scripts/bin/git/branch/`
- [ ] `scripts/bin/git/branch/` directory deleted if empty
