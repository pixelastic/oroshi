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

Any bats test that needs real SSH/SCP/rsync calls can use `bats_ssh_mock_start` (defined in `tools/term/bats/config/helper`). Call it in `setup_file()` — it's idempotent, so multiple test files can call it without conflict.

```bash
bats_load_library 'helper'

setup_file() {
  bats_ssh_mock_start
}

setup() {
  bats_tmp_dir
}

@test "transfers file via scp" {
  echo "data" > "$BATS_TMP_DIR/file.txt"
  run scp "$BATS_TMP_DIR/file.txt" "mock:$BATS_TMP_DIR/output.txt"
  [[ -f "$BATS_TMP_DIR/output.txt" ]]
}
```

The `/tmp/sandbox` mount is symmetric — same path inside and outside the container — so `$BATS_TMP_DIR` works directly as the assertion target. No path translation needed.

## Architecture

- **Container**: `ssh-mock`, port `2222` → `22`
- **User**: `mock` (UID/GID match host user)
- **Auth**: ed25519 key pair at `keys/id_mock` (committed, non-sensitive)
- **Mount**: `/tmp/sandbox` → `/tmp/sandbox` (symmetric)
