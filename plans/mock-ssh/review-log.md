## Issue 01 — Docker Foundation
### Use docker-container-remove helper
```zsh
docker rm --force "$CONTAINER_NAME" &>/dev/null || true
```
**Problem:** Standards say to prefer existing helpers over raw docker commands.
**Reason skipped:** `docker-container-remove` prints colored output with icons ("✔ container ... deleted") which is unwanted in an idempotent start script that should be silent on cleanup. Raw `docker rm --force` with suppressed output is the better fit here.

## Issue 03 — Integration tests
### No teardown_file for Docker container
```bats
setup_file() {
  bats_ssh_mock_start
}
```
**Problem:** No `teardown_file` to stop the container after tests.
**Reason skipped:** Container is intentionally persistent — `bats_ssh_mock_start` is idempotent and the container is reused across test runs.

### Spec names mock_ssh_host but code uses bats_ssh_mock_start
```bats
bats_ssh_mock_start
```
**Problem:** Spec says `mock_ssh_host` but code uses `bats_ssh_mock_start`.
**Reason skipped:** Spec is outdated — the helper was committed as `bats_ssh_mock_start` in issue 02.
