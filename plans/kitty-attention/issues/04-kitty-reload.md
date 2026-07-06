## TLDR

Rename `kitty-refresh` → `kitty-reload` and refactor it to use `kitty-redraw`.

## What to build

Rename the existing `scripts/bin/kitty/kitty-refresh` script to `kitty-reload`.
Refactor its internals to match the architecture defined in the Glossary:

1. Write the Reload Beacon file (same path as before)
2. Call `kitty-redraw` to trigger an immediate Tab Bar re-render

Remove the `kill -SIGUSR1` approach. The Tab Bar Python will detect the Reload
Beacon at the next Redraw and perform the full data reload.

Update all callers of `kitty-refresh` across the codebase to call `kitty-reload`.

## Scaffolding Tests

Verify that `kitty-refresh` no longer exists and `kitty-reload` takes its place.

## Acceptance criteria

- [ ] `scripts/bin/kitty/kitty-refresh` deleted
- [ ] `scripts/bin/kitty/kitty-reload` created with Reload Beacon + `kitty-redraw` logic
- [ ] All callers updated (grep confirms no remaining references to `kitty-refresh`)
- [ ] Script linted with `zsh-lint`
