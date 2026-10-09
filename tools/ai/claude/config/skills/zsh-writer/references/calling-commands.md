# Calling commands

## Prefer long-form args

- Prefer long-form args (`--type`, not `-t`) for readability
    - Exception: common short-form idioms are fine (`head -1`, `jq -r`, `mkdir -p`, `sed -n`, `tail -1`, etc)
- If multiple args, display one arg per line for better readability

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

Prefer existing helpers over raw commands
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
| And more... | Check `helper-list ...` |


Before falling back to porcelain, discover available helpers in two steps:

1. `helper-list <domain> [action]` lists helpers with their name and description.
2. `helper-documentation <name>` prints the full header of one helper, with its usage and flags.

Example:
```zsh
helper-list git branch
helper-documentation git-branch-copy
```

## Stderr suppression in subshells

- Only add `2>/dev/null` when the command is known to write to stderr
