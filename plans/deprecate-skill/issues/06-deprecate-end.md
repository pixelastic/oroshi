## TLDR

Script that executes all deprecation steps idempotently, calling `deprecate-prepare` for state.

## What to build

A ZSH script `deprecate-end` in `scripts/bin/ai/deprecate/` that takes a project name, calls `deprecate-prepare` to get state, then executes all deprecation steps in order.

### Steps (idempotent, fail-fast)

**GitHub block** (skip entirely if `github` is null or `isArchived` is true):

1. **Disable Renovate**: if `.github/renovate.json` exists in the cloned repo, overwrite with `{"enabled": false}`
2. **Commit + push**: only if there are uncommitted changes. Commit message: `DEPRECATED: <name> is now deprecated and archived`
3. **Update description**: call `git-github-repo-description-set` with `[DEPRECATED] <original description>`. Skip if description already starts with `[DEPRECATED]`.
4. **Archive**: call `git-github-repo-archive`. Skip if already archived.

**npm block** (skip if `npmPackage` is null or `npmIsDeprecated` is true):

5. **Check auth**: call `npm-is-logged-in`, fail with error if not logged in
6. **Deprecate**: call `npm-deprecate <name> "No longer maintained. See https://github.com/<owner>/<repo> for details."`

**projects.jsonc block** (skip if `inProjectsJsonc` is false):

7. **Remove**: call `project-remove <name>`
8. **Rebuild**: call `projects-build`

### Output

- Success: `{"status": "ok"}`
- Failure: `{"status": "error", "step": "<step-name>", "message": "<error details>"}`

### Idempotency

Each step checks "already done?" before executing. On re-run after a failure, completed steps are skipped and execution resumes at the failed step.

## Behavioral Tests

**Happy path (all helpers mocked):**
- calls all steps in order when nothing is done yet
- returns `{"status": "ok"}` on success

**Idempotency (mock deprecate-prepare with various states):**
- skips GitHub block when `isArchived` is true
- skips npm block when `npmIsDeprecated` is true
- skips projects.jsonc block when `inProjectsJsonc` is false
- skips commit+push when no uncommitted changes
- skips description update when already prefixed with `[DEPRECATED]`

**Fail-fast:**
- stops and returns error JSON when a step fails
- does not execute subsequent steps after failure

**npm auth guard:**
- fails with clear error when `npm-is-logged-in` returns false

## Acceptance criteria

- [ ] Calls `deprecate-prepare` internally to get state
- [ ] Executes all steps in correct order
- [ ] Each step is idempotent (skips if already done)
- [ ] Fails fast with `{"status": "error", ...}` on any step failure
- [ ] Returns `{"status": "ok"}` on full success
- [ ] Tests pass with all helpers mocked
