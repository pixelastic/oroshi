## TLDR

Create `fzf-js-test` picker for JS test files and wire it into CTRL-P for `yrt`, `yrtw`, `yrtff`.

## What to build

Create a new fzf picker script `fzf-js-test` that lists `.js` files inside `__tests__/` directories, using the same visual style as the default `ctrl-p` picker (context-badge prompt, directory-colored paths, filetype-colored filenames). The selected path is absolute.

The picker follows the standard fzf dispatch pattern:
- `fzf-source()`: uses `fd --type file --extension js --full-path '/__tests__/' --base-directory "$gitRoot"` to find files, then colorizes each path with `fzf-colorize-path`. Output format: `absolute_path▮colorized_relative_path`.
- `fzf-options()`: delegates to `fzf-options-files` for identical prompt/colors to `ctrl-p`.
- Postprocess and preview: defaults from `init.zsh` and `fzf-fs-preview.zsh`.

Add three entries to `specialPickers` in `ctrl-p.zsh`: `yrt`, `yrtw`, `yrtff` all pointing to `fzf-js-test`.

Prior art: `fzf-bats-test` (picker pattern), `ctrl-p` (display and options reuse).

## Behavioral Tests

Mock `fd` with `bats_mock` to return controlled file lists. Prior art: `__tests__/fzf-bats-test.bats`.

**Source output format:**
- `--source` first field is the absolute filepath
- `--source` second field is ANSI-colored
- `--source` outputs nothing when no test files exist

## Acceptance criteria

- [ ] `fzf-js-test --source` lists only `.js` files under `__tests__/` directories
- [ ] Display is identical to `ctrl-p` (context-badge prompt, directory/filetype colors)
- [ ] Selected path is absolute
- [ ] CTRL-P after `yrt`, `yrtw`, or `yrtff` dispatches to `fzf-js-test`
- [ ] Bats tests pass
