## Guidance

### What this plan builds

A persistent Docker SSH server reachable as `Host mock`, used by bats tests to exercise real `ssh`, `scp`, and `rsync` calls. After the plan is complete, any bats test can call `mock_ssh_host` in `setup_file` and immediately use `ssh mock`, `scp`, and `rsync mock:` against a real SSH stack.

### Key architectural decision

`/tmp/oroshi/` is mounted symmetrically into the container (same path inside and outside). This means `$BATS_TMP_DIR` — already per-test isolated by the bats helper — is the assertion target without any path translation. Parallel tests never collide.

### Testing commands

```zsh
# Run integration tests
bats tools/basics/ssh/mock/__tests__/mock.bats

# Lint the autoload functions
zsh-lint tools/term/zsh/config/functions/autoload/ssh/mock/ssh-mock-start
zsh-lint tools/term/zsh/config/functions/autoload/ssh/mock/ssh-mock-stop

# Lint bats files
bats-lint tools/basics/ssh/mock/__tests__/mock.bats
bats-lint tools/term/bats/config/helper
```

### File locations (relative to repo root)

- `tools/basics/ssh/mock/` — Docker image, keys, README
- `tools/basics/ssh/mock/keys/id_mock` — client key (committed, non-sensitive)
- `tools/basics/ssh/mock/keys/host_mock` — host key (committed, non-sensitive)
- `tools/term/zsh/config/functions/autoload/ssh/mock/ssh-mock-start` — start container
- `tools/term/zsh/config/functions/autoload/ssh/mock/ssh-mock-stop` — stop container
- `tools/basics/ssh/config/default` — SSH config (add `Host mock` block before `Host *`)
- `tools/term/bats/config/helper` — shared bats helper (add `mock_ssh_host`)
- `tools/basics/ssh/mock/__tests__/mock.bats` — integration tests

### Conventions

- ZSH scripts: use `zsh-writer` skill; follow existing scripts in `tools/basics/ssh/` as style reference
- Bats tests: load with `bats_load_library 'helper'`; all test variables in `setup()`; use `bats_tmp_dir` for sandbox
- Docker container name: `oroshi-mock-ssh`
- Docker port: `2222` → `22`
- SSH user inside container: `mock` (fixed username; UID/GID match host via build args)
- Key pair naming: `id_mock` / `id_mock.pub` — explicit mock purpose

### Prior art

- `tools/basics/ssh/deploy` — existing SSH deploy script; shows how `config/default` is concatenated
- `tools/term/bats/config/helper` — existing bats helper; follow the same function comment style and signature conventions
- `/home/tim/local/www/algolia/brefsearch/brefsearch-data/Dockerfile` — example of `ARG USER_ID/GROUP_ID` pattern for matching host UID/GID in Alpine

## Discoveries

### Issue 01 — Docker Foundation
- Alpine `adduser -D` creates a locked account; must `passwd -u mock` to allow SSH login
- `docker-container-is-running` helper exists and should be used instead of raw `docker ps | grep`
- `docker-container-remove` helper is too verbose (colored output with icons) for silent cleanup in start scripts — raw `docker rm --force` is acceptable there
- `~/.oroshi` is not the worktree — mock key must be copied to `~/.ssh/id_mock` by the deploy script, not referenced via `~/.oroshi/` path
- SSH config `IdentityFile` should use `~/.ssh/` (consistent with all other keys) not `~/.oroshi/`
