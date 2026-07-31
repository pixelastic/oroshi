## Issue 01 — Vale install
### Install location mechanism
```zsh
ln --force --symbolic "${INSTALL_PATH}/${BINARY_NAME}" .
```
**Problem:** Spec says "downloads the Vale binary to `~/local/bin/vale`" but implementation uses `~/local/etc/vale/` + symlink.
**Reason skipped:** Follows established repo pattern (taplo, jq, etc. all use `~/local/etc/` + symlink to `~/local/bin/`). Functional outcome matches spec intent.
