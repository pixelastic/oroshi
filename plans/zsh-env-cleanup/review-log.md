## Issue 02 — fix-zsh-config-path-heredoc-tests

### Spec: removal of `zshenv.zsh` source line not sanctioned
```bash
source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
```
**Problem:** Spec assumed the `zshenv.zsh` source line would remain (providing `$OROSHI_ROOT`); the diff removes it instead.
**Reason skipped:** The file was deleted in a prior commit (`1bf38229`). Removing the call is the only correct fix. `$OROSHI_ROOT` is available because `zsh -c` auto-sources `~/.zshenv`. Tests pass.

### Spec: unspecified changes (worktree name, bats_run_zsh style)
**Problem:** Worktree rename (`fix-bug` → `my-repo--fix-bug`) and `bats_run_zsh` API migration not mentioned in spec.
**Reason skipped:** Both were pre-existing breakages from prior commits (`201a549b`, `a0037922`) that blocked the acceptance criteria. Had to fix them to make the test suites pass as required.

### Standards: `source $OROSHI_ROOT/...` without quotes in heredoc
**Problem:** Paths containing `$OROSHI_ROOT` inside heredocs are unquoted.
**Reason skipped:** Pre-existing pattern throughout the file; `$OROSHI_ROOT` is guaranteed not to contain spaces by zshenv design. No regression introduced.
