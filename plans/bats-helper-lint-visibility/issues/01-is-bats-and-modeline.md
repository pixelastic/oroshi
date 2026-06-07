## TLDR

Create the `is-bats` predicate function with tests, and fix the vim modelines + `noRunZsh` disables in both helper files.

## What to build

Create the `is-bats` autoload function in the `term/bats` subdomain. It takes a filepath and exits 0 if the file is a BATS file, 1 otherwise. Detection order: symlinks and non-regular-files are rejected first; files with a `.bats` extension are accepted; files with any other extension are rejected; extensionless files with `# vim: set ft=bats:` on line 1 are accepted; everything else is rejected. Modeled structurally after `is-zsh`.

Write a full unit test suite for `is-bats` covering all branches of the detection matrix.

In the two BATS helper files (`helper` and `rules-helper`), change the modeline from `ft=bash` to `ft=bats` on line 1 — this enables `is-bats` detection and fixes NeoVim syntax highlighting. Also add a `# bats-lint disable=noRunZsh` comment above each `run zsh` line (4 in `helper`, 1 in `rules-helper`), since those calls are the legitimate underlying implementation of `bats_run_zsh` and `run_rule`.

## Behavioral Tests

**`is-bats` — extension cases**
- exits 0 for a `.bats` file
- exits 1 for a `.zsh` file
- exits 1 for a `.js` file

**`is-bats` — extensionless cases**
- exits 0 for an extensionless file with `ft=bats` modeline on line 1
- exits 1 for an extensionless file with `ft=bash` modeline on line 1
- exits 1 for an extensionless file with no modeline

**`is-bats` — edge cases**
- exits 1 for a symlink to a `.bats` file
- exits 1 for a directory path

## Acceptance criteria

- [ ] `is-bats` lives in the `term/bats` autoload subdomain
- [ ] `is-bats` exits 0 for `*.bats` files and extensionless files with `ft=bats` on line 1
- [ ] `is-bats` exits 1 for all other inputs (other extensions, wrong modeline, symlinks, directories)
- [ ] Unit test file exists alongside other `term/bats` tests, all tests pass
- [ ] `helper` and `rules-helper` modelines changed to `ft=bats`
- [ ] `# bats-lint disable=noRunZsh` added above each `run zsh` line in both helper files
- [ ] `bats-lint helper` and `bats-lint rules-helper` exit 0
