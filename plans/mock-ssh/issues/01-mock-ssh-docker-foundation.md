## TLDR

Build the Alpine SSH server Docker image, key pair, start script, SSH config block, and README.

## What to build

Create `tools/basics/ssh/mock/` with everything needed to run a local SSH server in Docker:

- **Dockerfile**: Alpine + openssh. Accepts `USER_ID` and `GROUP_ID` build arguments. Creates a fixed `mock` user with those UID/GID. Copies the public key into `authorized_keys`. Runs sshd on port 22. No entrypoint script — user creation happens in the `RUN` layer.
- **Key pair**: Pre-generated ed25519 dummy keys at `keys/id_mock` and `keys/id_mock.pub`. No passphrase. Committed to the repo — these are non-sensitive (localhost-only, test-only).
- **`start` script**: ZSH script. Idempotent — checks if the container `oroshi-mock-ssh` is already running; if yes, exits cleanly. If no, builds the image (passing `USER_ID=$(id -u)` and `GROUP_ID=$(id -g)` as build args) and starts the container with port 2222 mapped to container port 22, and `/tmp/oroshi` mounted at `/tmp/oroshi` inside the container.
- **`Host mock` block**: Added to `config/default` (before the existing `Host *` catch-all). Settings: `HostName localhost`, `Port 2222`, `User mock`, `ControlMaster no`, `StrictHostKeyChecking no`, `UserKnownHostsFile /dev/null`. `IdentityFile` points to the committed key via `~/.oroshi/`.
- **`README.md`**: Explains what the mock SSH host is, how to start it, and how to use it in bats tests.

## Acceptance criteria

- [ ] `docker build` succeeds from `tools/basics/ssh/mock/`
- [ ] Running `start` builds the image and starts the container
- [ ] Running `start` a second time is a no-op (no duplicate container)
- [ ] After running the SSH deploy script, `~/.ssh/config` contains the `Host mock` block
- [ ] `ssh mock "echo hello"` returns `hello` from the terminal (manual verification)
- [ ] `scp /tmp/test.txt mock:/tmp/test.txt` transfers the file (manual verification)
- [ ] Files written via SSH are owned by the current host user (UID match)
- [ ] `bats-lint` passes on the `start` script
- [ ] `zsh-lint` passes on the `start` script
