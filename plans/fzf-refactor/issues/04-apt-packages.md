## TLDR

Migrate the apt package search to a FZF Script (domain script, no keybinding).

## What to build

Create `scripts/bin/fzf/apt-packages` following the pattern from issue 02.
This is a domain FZF Script — it has no keybinding and is called directly by other scripts
(`apt-install`, `apt-search`, `apt-uninstall`).

The script sources a cached package list (the cache generation logic currently lives in
`fzf-packages-apt-source-generate`) and presents it in fzf. The postprocess extracts the
package name from the selection.

The installed-only variant (currently `fzf-packages-apt-installed`) becomes a flag or a
second script — check the current implementation to decide which is cleaner.

Update callers (`apt-install`, `apt-search`, `apt-uninstall`) to call the new script.
Delete legacy autoloads for the entire `packages/apt/` domain.

## Behavioral Tests

**fzf-source**
- Outputs one package name per line (or package name + description, depending on format)
- The installed-only variant outputs only currently installed packages

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the package name only (no description)
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/apt-packages` created as executable `#!/bin/zsh` script
- [ ] `apt-packages --source` outputs available packages
- [ ] `apt-packages --source --installed` (or equivalent) outputs only installed packages
- [ ] `apt-packages --postprocess` (stdin) returns clean package name
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] `apt-install`, `apt-search`, `apt-uninstall` updated to call new script
- [ ] Legacy autoloads in `packages/apt/` deleted
- [ ] `zshlint` passes on all modified files
