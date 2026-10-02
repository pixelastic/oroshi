# Runtime folders: STATE vs CACHE

When a script writes runtime data to disk, pick the folder by whether the data
must survive a reboot.

| Variable | Path | Survives reboot? | Use for |
|---|---|---|---|
| `$OROSHI_FOLDER_STATE` | `$HOME/local/tmp/oroshi` | Yes | Data that must persist: session dumps, saved layouts, caches worth keeping |
| `$OROSHI_FOLDER_CACHE` | `/tmp/oroshi` | No — lost on reboot or 30-day age cleanup | Throw-away runtime files: sockets, PID/uuid markers, beacons, notification lists |

Default to `STATE`. Reach for `CACHE` only when losing the file on reboot is
harmless (or desirable, as with stale sockets).
