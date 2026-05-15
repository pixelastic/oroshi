# 0011 — `git-worktree-create` — auto yarn install

## What to build

After creating and `cd`-ing into the new worktree, check if `yarn.lock` exists
at the worktree root. If it does, run `yarn install || true`.

The check goes at the end of `git-worktree-create`, after the final `cd`:

```zsh
[[ -f "yarn.lock" ]] && yarn install || true
```

This is yarn-only: `package-lock.json` and `pnpm-lock.yaml` are out of scope.
The idempotent early-return path (`[[ -d "$worktreeDir" ]] && cd … && return 0`)
is not changed — re-entering an existing worktree does not re-run `yarn install`.

## Acceptance criteria

- [ ] Creating a worktree from a repo with `yarn.lock` automatically runs `yarn install`
- [ ] `node_modules/` exists in the new worktree after creation
- [ ] Creating a worktree from a repo without `yarn.lock` does not run `yarn install`
- [ ] A failing `yarn install` does not prevent the worktree from being created (function exits 0)
- [ ] Re-entering an already-existing worktree does not re-run `yarn install`

## Blocked by

None — can start immediately.
