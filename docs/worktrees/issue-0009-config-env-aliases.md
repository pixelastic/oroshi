# issue-0009 — config: env var, color alias, aliases, compdef

Wires everything together: environment variable, color, aliases, compdef bindings.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-config.bats

@test "OROSHI_WORKTREES_DIR is exported" {
  run zsh -c 'source ~/.oroshi/config/term/zsh/zshenv.zsh && echo $OROSHI_WORKTREES_DIR'
  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "vwtc alias exists" {
  run zsh -i -c 'which vwtc'
  [ "$status" -eq 0 ]
}

@test "vwtl alias exists" {
  run zsh -i -c 'which vwtl'
  [ "$status" -eq 0 ]
}

@test "vwts alias exists" {
  run zsh -i -c 'which vwts'
  [ "$status" -eq 0 ]
}

@test "vwtR alias exists" {
  run zsh -i -c 'which vwtR'
  [ "$status" -eq 0 ]
}
```

## What to implement

1. **`config/term/zsh/zshenv.zsh`** — add `export OROSHI_WORKTREES_DIR=~/local/www/worktrees`

2. **`config/term/zsh/theming/src/env-generate-colors`** — add `aliasColors[GIT_WORKTREE]="EMERALD"`, then regenerate to produce `$COLOR_ALIAS_GIT_WORKTREE`

3. **`config/term/zsh/aliases/git/worktree.zsh`** — new file:
   ```
   alias vwtc='git-worktree-create'
   alias vwtl='git-worktree-list'
   alias vwts='git-worktree-switch'
   alias vwtR='git-worktree-delete'
   ```

4. **`config/term/zsh/completion/compdef.zsh`** — add under the Git section:
   ```
   compdef _git-branches-local git-worktree-create
   compdef _git-worktrees git-worktree-switch git-worktree-delete
   ```
