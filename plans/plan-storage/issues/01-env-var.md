## TLDR

Define `$OROSHI_PLANS_DIR` environment variable in `zshenv-host.zsh`.

## What to build

Add `OROSHI_PLANS_DIR` to `tools/term/zsh/config/zshenv-host.zsh`, following the same pattern as `OROSHI_WORKTREES_DIR`:

```
export OROSHI_PLANS_DIR="${MOCK_OROSHI_PLANS_DIR:-$HOME/local/www/plans}"
```

Place it right after the `OROSHI_WORKTREES_DIR` definition. Create the directory if it doesn't exist (`mkdir -p`).

## Behavioral Tests

**Skip** — pure configuration, no logic to test. The variable is exercised by every subsequent issue.

## Acceptance criteria

- [ ] `$OROSHI_PLANS_DIR` is exported and resolves to `~/local/www/plans`
- [ ] `MOCK_OROSHI_PLANS_DIR` overrides it when set
- [ ] `~/local/www/plans/` directory exists on disk
