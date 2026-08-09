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
| And more... | Check `helper-list-raw ...` |


Before falling back to porcelain, run `helper-list-raw` to discover available helpers.

```
Example:
```zsh
helper-list-raw git
git-branch-copy▮Copy a branch▮{filepath}
git-branch-pull▮Pull a branch▮{filepath}
git-branch-list▮Display the list of local branches▮{filepath}
# ...
```

## Stderr suppression in subshells

- Only add `2>/dev/null` when the command is known to write to stderr
