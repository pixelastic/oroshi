# Mock SSH Host

Local Docker container running an Alpine SSH server, used by bats tests to exercise real `ssh`, `scp`, and `rsync` calls.

## Start / Stop

```zsh
ssh-mock-start   # Build image and start container (idempotent)
ssh-mock-stop    # Stop and remove container
```

## Usage

After running the SSH deploy script (`tools/basics/ssh/deploy`), the `Host mock` block is added to `~/.ssh/config` and the mock key is copied to `~/.ssh/id_mock`:

```zsh
ssh mock "echo hello"
scp /tmp/test.txt mock:/tmp/test.txt
rsync -a /tmp/src/ mock:/tmp/dest/
```

## In bats tests

Call `mock_ssh_host` in `setup_file()` to ensure the container is running:

```bash
setup_file() {
  mock_ssh_host
}

@test "transfers file via scp" {
  scp "$BATS_TMP_DIR/file.txt" mock:"$BATS_TMP_DIR/file.txt"
  [ -f "$BATS_TMP_DIR/file.txt" ]
}
```

The `/tmp/oroshi` mount is symmetric — same path inside and outside the container — so `$BATS_TMP_DIR` works directly as the assertion target.

## Architecture

- **Container**: `oroshi-mock-ssh`, port `2222` → `22`
- **User**: `mock` (UID/GID match host user)
- **Auth**: ed25519 key pair at `keys/id_mock` (committed, non-sensitive)
- **Mount**: `/tmp/oroshi` → `/tmp/oroshi` (symmetric)
