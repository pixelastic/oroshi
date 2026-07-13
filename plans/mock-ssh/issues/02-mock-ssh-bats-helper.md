## TLDR

Add `mock_ssh_host` to the shared bats helper so tests can start the mock SSH container idempotently.

## What to build

Add a `mock_ssh_host` function to `tools/term/bats/config/helper`, following the same style as existing helpers (`bats_tmp_dir`, `bats_git_dir`, etc.).

The function is idempotent: it checks whether the `oroshi-mock-ssh` container is already running. If yes, it returns immediately. If no, it calls `ssh-mock-start`.

Intended usage: called once in `setup_file()` in any bats test file that needs a real SSH target.

Because `mock_ssh_host` lives in the shared helper, it is available to all bats tests without any extra `source` or `bats_load_library` call.

## Acceptance criteria

- [ ] `mock_ssh_host` is defined in `tools/term/bats/config/helper`
- [ ] Calling `mock_ssh_host` when the container is not running starts it
- [ ] Calling `mock_ssh_host` when the container is already running does not create a second container
- [ ] `bats-lint` passes on the updated helper
