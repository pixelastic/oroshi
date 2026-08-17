## TLDR

Replace `rtk-can-rewrite` with `rtk-command-rewrite`, wire it into the hook, delete the wrapper.

## What to build

Create `rtk-command-rewrite` as a ZSH autoload function at `tools/term/zsh/config/functions/autoload/ai/rtk/rtk-command-rewrite`. It takes a command string and prints the rewritten form:

- If input starts with `rtk `, print unchanged (idempotency)
- If `rtk rewrite "$cmd"` succeeds, print its stdout (native rewrite, e.g. `rtk git status`)
- If input matches `^bats( |$)`, `^yarn run test( |$)`, or `^python-test( |$)`, print `rtk bin-zsh $cmd`
- Otherwise, print unchanged (pass-through)

Always exits 0.

Then wire it into the hook:
- In `preToolUse-Bash`, replace the `preToolUse-Bash-rtk` call (line 54) with a direct call to `rtk-command-rewrite`
- Remove the `source preToolUse-Bash-rtk.zsh` line
- Delete `preToolUse-Bash-rtk.zsh` and `__tests__/preToolUse-Bash-rtk.bats`
- Delete `rtk-can-rewrite` and `__tests__/rtk-can-rewrite.bats`

Housekeeping:
- In `allow-list.json`, rename `rtk-can-rewrite` to `rtk-command-rewrite`
- In `GLOSSARY.md`, update the function name and describe the new contract (returns rewritten command, not boolean)

## Behavioral Tests

**Native rewrite (RTK built-in):**
- returns `rtk git status` for `git status`
- returns `rtk git diff --stat` for `git diff --stat`

**Filter-backed rewrite (ZSH + bin-zsh):**
- returns `rtk bin-zsh bats foo.bats` for `bats foo.bats`
- returns `rtk bin-zsh yarn run test foo.js` for `yarn run test foo.js`
- returns `rtk bin-zsh python-test foo.py` for `python-test foo.py`

**Pass-through:**
- returns `echo hello` for `echo hello`
- returns `yarn install` for `yarn install`

**Idempotency:**
- returns `rtk git status` unchanged for `rtk git status`

**No false positives:**
- returns `bats-lint foo.bats` unchanged for `bats-lint foo.bats`
- returns `python-test-something` unchanged for `python-test-something`

## Acceptance criteria

- [ ] `rtk-command-rewrite` exists and passes all behavioral tests
- [ ] `rtk-can-rewrite` deleted
- [ ] `preToolUse-Bash-rtk.zsh` and its tests deleted
- [ ] `preToolUse-Bash` calls `rtk-command-rewrite` directly
- [ ] `allow-list.json` entry renamed
- [ ] `GLOSSARY.md` updated
- [ ] Existing `preToolUse-Bash` integration tests still pass
