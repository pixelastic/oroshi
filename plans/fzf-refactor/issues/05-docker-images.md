## TLDR

Migrate the Docker Hub image search to a FZF Script (domain script, no keybinding).

## What to build

Create `scripts/bin/fzf/fzf-docker-images` following the pattern from issue 02.
This is a domain FZF Script — it has no keybinding and is called directly by `docker-image-pull`.

The script queries the Docker Hub API for image results matching the user's query,
presents them in fzf with a preview showing image metadata, and returns the selected
`image:tag` string.

Update `docker-image-pull` to call the new script.
Delete legacy autoloads for the entire `docker/images/remote/` domain.

## Behavioral Tests

**fzf-source**
- Outputs one `image:tag` candidate per line
- Handles empty query gracefully (outputs nothing or a helpful message)

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs `image:tag` format suitable for `docker pull`
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/fzf-docker-images` created as executable `#!/bin/zsh` script
- [ ] `docker-images --source` outputs Docker Hub candidates
- [ ] `docker-images --postprocess` (stdin) returns `image:tag` string
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] `docker-image-pull` updated to call new script
- [ ] Legacy autoloads in `docker/images/remote/` deleted
- [ ] `zsh-lint` passes on all modified files
