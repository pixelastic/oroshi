## TLDR

Refactor `ctrl-p` to delegate its file listing to `fzf-source-files`, removing the inlined loop.

## What to build

In `ctrl-p`:
- Replace the `source fzf-colorize-path` line with `source fzf-source-files` (which pulls in `fzf-colorize-path` transitively).
- Replace the inlined `fzf-source` function body with a single delegation call to `fzf-source-files`, passing the git root search path.
- Remove the script-level `colors-load-definitions` and `filetypes-load-definitions` calls — these are now handled inside the lib functions that need them.
- Add `colors-load-definitions` inside `fzf-options`, which references `$COLORS[file]`.

No new behavior is added. The output of `ctrl-p --source` must be identical to before the refactor (same colorization, same two-column format, same postprocess behavior).

## Scaffolding Tests

None — this is a pure refactor. The existing `ctrl-p.bats` suite verifies behavioral equivalence.

## Acceptance criteria

- [ ] `ctrl-p` sources `fzf-source-files` and delegates `fzf-source` to it
- [ ] Script-level `colors-load-definitions` / `filetypes-load-definitions` calls removed from `ctrl-p`
- [ ] `colors-load-definitions` called inside `fzf-options` in `ctrl-p`
- [ ] All existing `ctrl-p.bats` tests pass unchanged
- [ ] `zsh-lint` passes on `ctrl-p`
