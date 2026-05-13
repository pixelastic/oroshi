## What to build

Add `--workspace PATH` flag to `claude-sandbox` so that the caller can target
a directory other than `$PWD`.

The flag is consumed by `claude-sandbox` and never forwarded to Claude.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] `claude-sandbox "prompt" --workspace /some/path` mounts `/some/path` as the workspace
- [ ] `claude-sandbox "prompt"` still defaults to `$PWD` when `--workspace` is absent
- [ ] Passing a non-existent path prints a clear error and exits 1 before starting Docker
- [ ] `--workspace` does not appear in the args forwarded to Claude
- [ ] Bats test passes

## Blocked by

- issue-02-basic-sandbox
