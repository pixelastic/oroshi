## Issue 01 — Migrate source data

### Inconsistent nesting for node, ruby, claude-mcp-context7

```jsonc
"node":                  "",
"node-version-current":  "",
"node-install-in-progress": "",
...
"ruby":                   "",
"ruby-install-in-progress": "",
```

**Problem:** Spec says "organize entries into nested objects by category" — node, ruby, claude-mcp-context7 are left as flat keys rather than nested under `"node"`, `"ruby"` objects.

**Reason skipped:** JSON does not allow a key to be both a scalar string and an object simultaneously. `"node": ""` and `"node": { "version-current": "" }` cannot coexist. These categories have bare keys (the category name itself is an icon key), so flat entries are the only valid representation. The `paths | join("-")` flattening in `colors-build` handles flat keys correctly alongside nested groups.
