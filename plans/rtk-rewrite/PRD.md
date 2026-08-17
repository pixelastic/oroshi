## Problem Statement

RTK should intercept git commands (`git status`, `git diff`, `git log`) run by Claude and rewrite them for token-optimized output. Instead, Claude gets full verbose git output because the hook always prepends `rtk bin-zsh` to every rewritable command. For git commands, RTK sees `bin-zsh git status` and doesn't recognize it as a git command — no compression happens.

The root cause is that `preToolUse-Bash-rtk` treats all rewritable commands identically (`rtk bin-zsh <cmd>`), but RTK-native commands (git, ls) need `rtk <cmd>` while filter-backed ZSH functions (bats, python-test) need `rtk bin-zsh <cmd>`.

## Solution

Replace the boolean `rtk-can-rewrite` function with `rtk-command-rewrite`, a command-rewriting function that returns the correctly rewritten form for any command. Remove the `preToolUse-Bash-rtk.zsh` wrapper and call `rtk-command-rewrite` directly from the hook.

The new function handles three cases:
1. RTK-native commands: ask `rtk rewrite` for the correct form (e.g. `rtk git status`)
2. Filter-backed ZSH commands: prepend `rtk bin-zsh` (e.g. `rtk bin-zsh bats foo`)
3. Everything else: pass-through unchanged

## User Stories

1. As Claude, I want git status output to be token-compressed, so that I consume fewer tokens per status check
2. As Claude, I want git diff output to be token-compressed, so that diffs don't waste context window
3. As Claude, I want git log output to be token-compressed, so that commit history is concise
4. As Claude, I want bats test output to still be filtered through RTK with bin-zsh, so that only failing tests are shown
5. As Claude, I want yarn test output to still be filtered through RTK with bin-zsh, so that only failing tests are shown
6. As Claude, I want python-test output to still be filtered through RTK with bin-zsh, so that only failing tests are shown
7. As Claude, I want commands already prefixed with `rtk` to pass through unchanged, so that double-wrapping never happens
8. As Claude, I want unrecognized commands to pass through unchanged, so that only known commands are rewritten
9. As a developer, I want a single entry point (`rtk-command-rewrite`) that hides the native vs filter distinction, so that callers don't deal with implementation details
10. As a developer, I want the hook pipeline to remain simple — Solkan then RTK rewrite — so that debugging is straightforward

## Implementation Decisions

- **Rename `rtk-can-rewrite` to `rtk-command-rewrite`**: the old name implies a boolean; the new function always returns the (possibly unchanged) command
- **Always exit 0, always print**: the function is a pure transform, not a predicate. Callers use stdout, never the exit code
- **Idempotency guard inside `rtk-command-rewrite`**: if input starts with `rtk `, return it unchanged. No caller needs to worry about double-wrapping
- **Delete `preToolUse-Bash-rtk.zsh`**: with the logic in `rtk-command-rewrite`, the wrapper adds no value. Call `rtk-command-rewrite` directly from `preToolUse-Bash`
- **Two rewrite paths inside `rtk-command-rewrite`**: (1) `rtk rewrite "$cmd"` for native commands, (2) hardcoded patterns + `rtk bin-zsh` for filter-backed ZSH functions. The distinction is internal — callers see one interface
- **Update `allow-list.json`**: rename `rtk-can-rewrite` entry to `rtk-command-rewrite`
- **Update `GLOSSARY.md`**: rename function reference, update contract description from boolean to command-returning

## Testing Decisions

- Test `rtk-command-rewrite` in isolation via bats — it is the only module with real logic
- Test cases cover all three paths: native rewrite, filter+bin-zsh, pass-through, plus idempotency and false-positive guards
- Prior art: `__tests__/rtk-can-rewrite.bats` (same location, same test helper patterns)
- `preToolUse-Bash` integration tests should continue passing — output shape unchanged, only internal wiring changes
- No new tests needed for `preToolUse-Bash` itself — existing integration tests cover the end-to-end flow

## Out of Scope

- Adding new RTK filter definitions (TOML filters for new commands)
- Modifying RTK itself (the Rust binary)
- Changing the Solkan layer or rewrite-list system
- Teaching RTK to natively handle bats/yarn/python-test (would eliminate the bin-zsh path but requires upstream changes)

## Further Notes

- The rmdir-hooks sidequest previously fixed a related bug (Solkan field mismatch `.rewrittenCommand` vs `.rewrite`). That fix is already merged and unrelated to this issue.
- `rtk bin-zsh git status` doesn't crash — it just doesn't compress. RTK treats `bin-zsh` as an unknown command and passes output through unfiltered. The bug is silent token waste, not an error.
