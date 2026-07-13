## Issue 01 — Docker Foundation
### Use docker-container-remove helper
```zsh
docker rm --force "$CONTAINER_NAME" &>/dev/null || true
```
**Problem:** Standards say to prefer existing helpers over raw docker commands.
**Reason skipped:** `docker-container-remove` prints colored output with icons ("✔ container ... deleted") which is unwanted in an idempotent start script that should be silent on cleanup. Raw `docker rm --force` with suppressed output is the better fit here.
