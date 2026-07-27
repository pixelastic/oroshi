## TLDR

Script that gathers all deprecation-relevant info about a project and returns it as JSON.

## What to build

A ZSH script `deprecate-prepare` in `scripts/bin/ai/deprecate/` that takes a project name and returns JSON with the full state needed for deprecation.

### Lookup flow

1. Check `project-exists` — if found, get path via `project-path`, check disk exists, read `git-github-project-owner` / `git-github-project-name` from git remote
2. If not in projects.jsonc — try `git-github-repo-exists pixelastic/<name>`
3. If not on GitHub — return `{"status": "not-found"}`
4. Disk resolution: check project path first, then `/tmp/oroshi/deprecate/<name>/`, otherwise clone there (only if owner is `pixelastic`)
5. Read npm package name via `yarn-package-name` (if package.json exists and not private), check `npm-is-published`, `npm-is-deprecated`
6. If npm package exists, check `npm-is-logged-in`

### JSON output

```json
{
  "status": "ok",
  "projectName": "callirhoe",
  "inProjectsJsonc": true,
  "github": {
    "owner": "pixelastic",
    "repo": "callirhoe",
    "description": "~ Simplified API",
    "isArchived": false
  },
  "clonedAt": "/home/user/local/www/projects/callirhoe",
  "npmPackage": "callirhoe",
  "npmIsDeprecated": false,
  "npmIsLoggedIn": false
}
```

- `github`: `null` if not found on GitHub
- `npmPackage`: `null` if no package.json, private, or not published
- `npmIsDeprecated` / `npmIsLoggedIn`: only present when `npmPackage` is not null

### Idempotency

- If repo already cloned at `/tmp/oroshi/deprecate/<name>/`, reuse it
- Multiple calls return the same JSON (modulo live API state)

## Behavioral Tests

**Lookup paths (mock all domain helpers):**
- project in projects.jsonc with path on disk → uses that path, reads git remote
- project in projects.jsonc but path doesn't exist on disk → clones to temp
- project not in projects.jsonc but on GitHub as pixelastic/<name> → clones to temp
- project not in projects.jsonc, not on GitHub → status "not-found"
- project owned by someone other than pixelastic → no clone, still returns info

**Temp clone idempotency:**
- repo already at `/tmp/oroshi/deprecate/<name>/` → skips clone, returns that path

**npm detection:**
- package.json exists and not private, published → npmPackage set, checks deprecated + logged in
- package.json exists but private → npmPackage null
- no package.json → npmPackage null

## Acceptance criteria

- [ ] Returns valid JSON matching the schema above
- [ ] Lookup flow follows the priority: projects.jsonc → GitHub → not-found
- [ ] Clones to `/tmp/oroshi/deprecate/<name>/` when repo not on disk
- [ ] Idempotent: reuses existing temp clone
- [ ] npm fields correctly populated based on package.json and registry state
- [ ] Tests pass with all domain helpers mocked
