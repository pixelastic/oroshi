# Calling commands

- Prefer long-form args (`--type`, not `-t`)
- Prefer existing helpers over raw commands (`git-branch-current`)
- One arg per line when multiple args
- Exception: common short-form idioms are fine:
    - `jq -r`
    - `head -1`
    - `tail -1`
    - `mkdir -p`

## Example
```zsh
# ✅
fd \
  --type file \
  --glob "*.md" \
  /path

# ❌
fd -t f -g "*.md" /path

```

## Prefer existing helpers

Before calling a porcelain command, check if an existing helper wraps it.
Helpers expose a stable interface and handle edge cases already.
Calling porcelain bypasses that work and creates duplication.


| Helper Examples | Instead of |
|---|---|
| `git-branch-exists main` | `git show-ref --verify refs/heads/main` |
| `git-directory-root` | `git rev-parse --show-toplevel` |
| `git-file-list-dirty-raw` | `git status --porcelain` |
| `git-worktree-list-raw` | `git worktree list --porcelain` |
| `docker-container-is-running web` | `docker inspect -f '{{.State.Running}}' web` |
| `docker-container-stop web` | `docker stop $(docker ps -q --filter name=web)` |
| `node-module-list-raw` | `npm list --global --depth=0` |
| And more... | Check in `tools/term/zsh/config/functions/autoload/` |


All helpers:
!`tree ~/.oroshi/tools/term/zsh/config/functions/autoload/`
