## TLDR

Replace oroshi-specific paths and container name with generic equivalents across SSH mock and bats helper.

## What to build

Rename the Docker container from `oroshi-mock-ssh` to `ssh-mock` and change the symmetric mount from `/tmp/oroshi` to `/tmp/sandbox` in `ssh-mock-start`. Update `ssh-mock-stop` with the new container name. Change the bats sandbox root in `bats_tmp_dir()` from `/tmp/oroshi` to `/tmp/sandbox`. Update the hardcoded coordination file path in `helper-default-teardown.bats`. Update `README.md` to reflect all changes.

Five files, ~10 lines changed:

- `tools/term/zsh/config/functions/autoload/ssh/mock/ssh-mock-start` — container name + mount path
- `tools/term/zsh/config/functions/autoload/ssh/mock/ssh-mock-stop` — container name
- `tools/term/bats/config/helper` — `bats_tmp_dir()` root path
- `tools/term/bats/config/__tests__/helper-default-teardown.bats` — coordination file path
- `tools/basics/ssh/mock/README.md` — documentation

## Acceptance criteria

- [ ] `ssh-mock-start` mounts `/tmp/sandbox:/tmp/sandbox` and uses container name `ssh-mock`
- [ ] `ssh-mock-stop` uses container name `ssh-mock`
- [ ] `bats_tmp_dir()` creates sandboxes under `/tmp/sandbox/bats/`
- [ ] `helper-default-teardown.bats` coordination file is under `/tmp/sandbox/bats/`
- [ ] `README.md` references `ssh-mock` container and `/tmp/sandbox` mount
- [ ] `mock.bats` passes
- [ ] `helper.bats` passes
- [ ] `helper-default-teardown.bats` passes
