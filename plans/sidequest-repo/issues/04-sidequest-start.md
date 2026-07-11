## TLDR

Create `sidequest-start [<project-name>]` — a ZSH script that resolves a project name (or CWD) to a path and returns JSON for the skill to consume.

## What to build

A new script at `scripts/bin/ai/sidequest/sidequest-start`. It accepts an optional project name argument and always returns JSON.

**Resolution logic:**

1. If a name is given, try `project-path <name>`.
2. If no name is given, try `project-name` (resolves `$PWD`) then `project-path` on the result.
3. If resolution succeeds → return `ok` with `projectName` and `projectPath`.
4. If resolution fails → return `unknown` with `candidates`: all registered projects as `{projectName, projectPath}` objects (sourced from the `PROJECTS` assoc array via `projects-load-definitions`).

**Output shapes:**

```json
{ "status": "ok", "projectName": "oroshi", "projectPath": "/home/tim/local/www/oroshi" }
{ "status": "unknown", "candidates": [{ "projectName": "oroshi", "projectPath": "/home/tim/local/www/oroshi" }, ...] }
```

**Skill update:** Update `SKILL.md` Step 1 to call `sidequest-start [<project-name>]` and interpret its output:
- `ok` → pass `--repo-dir <projectPath>` to `sidequest`
- `unknown` → pick the closest `projectName` from `candidates` (semantic match), confirm with user ("Did you mean `<name>`?"), then use its `projectPath`

## Behavioral Tests

**No argument, CWD is a known project:**
- returns `ok` with the resolved project name and path

**No argument, CWD is not a known project:**
- returns `unknown` with a non-empty `candidates` array

**Known project name:**
- returns `ok` with the correct project name and path

**Unknown project name:**
- returns `unknown` with a non-empty `candidates` array

## Acceptance criteria

- [ ] `sidequest-start` with no arg falls back to CWD resolution via `project-name`
- [ ] `sidequest-start <known-name>` returns `{"status":"ok","projectName":...,"projectPath":...}`
- [ ] `sidequest-start <unknown-name>` returns `{"status":"unknown","candidates":[...]}`
- [ ] CWD not a known project returns `{"status":"unknown","candidates":[...]}`
- [ ] `candidates` contains all registered projects as `{projectName, projectPath}` objects
- [ ] Bats tests for all four cases pass
- [ ] `SKILL.md` Step 1 updated to call `sidequest-start` and handle `ok`/`unknown`
