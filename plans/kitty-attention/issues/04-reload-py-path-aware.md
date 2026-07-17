## TLDR

Make `reload.py` load modules from the path written in the Reload Beacon.

## What to build

Modify `tools/term/kitty/config/lib/reload.py` to:

1. Read the Reload Beacon content (a path like `/home/tim/.oroshi` or a worktree
   path) instead of just checking existence
2. For each `lib.*` module in `sys.modules`, construct the file path under
   `{beacon_path}/tools/term/kitty/config/lib/{module_name}.py`
3. Use `importlib.util.spec_from_file_location` to load each module from that
   specific file path — no `sys.path` modification
4. Delete the beacon after loading
5. Re-run `init()` functions as before

## Acceptance criteria

- [ ] Modules are loaded from the path specified in the Reload Beacon
- [ ] `sys.path` is never modified
- [ ] Beacon is deleted after loading
- [ ] `init()` functions are re-run after module reload
