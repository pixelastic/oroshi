## Problem Statement

Deprecating projects during the projects.jsonc cleanup is repetitive and multi-step: check GitHub, update README, update description, archive, npm deprecate, remove from projects.jsonc, rebuild dist files. This process should be automated as a reusable skill with supporting scripts.

## Solution

A `/deprecate` skill that lets the user say a project name, dictate a deprecation reason (rewritten to proper English by the agent), confirm a plan, and have everything executed automatically. Deterministic steps live in scripts (`deprecate-prepare`, `deprecate-end`), reasoning steps live in the skill.

## User Stories

1. As a developer, I want to deprecate a project by name, so that I don't have to remember and execute each step manually
2. As a developer, I want to dictate the deprecation reason roughly, so that the agent rewrites it in proper English for the README
3. As a developer, I want to see a plan of what will happen before confirming, so that I can catch mistakes before destructive operations
4. As a developer, I want the deprecation to handle GitHub repos not in projects.jsonc, so that I can deprecate any repo under my account
5. As a developer, I want the process to clone the repo to a temp dir if not on disk, so that I always have files to work with
6. As a developer, I want npm deprecation to be handled automatically, so that published packages get a deprecation notice pointing to the GitHub repo
7. As a developer, I want Renovate to be disabled before archiving, so that no background activity runs on a dead repo
8. As a developer, I want the README to get a blockquote deprecation notice at the top, so that visitors immediately see the project is deprecated
9. As a developer, I want projects.jsonc updated without losing comments, so that the JSONC format is preserved
10. As a developer, I want the process to be idempotent, so that I can re-run it if a step fails and it resumes where it left off
11. As a developer, I want a warning if I'm not logged in to npm, so that I can fix auth before the process starts
12. As a developer, I want the GitHub description prefixed with `[DEPRECATED]`, so that it's visible in repo listings
13. As a developer, I want the entry removed from projects.jsonc and dist files rebuilt, so that the project no longer appears in my terminal theming
14. As a developer, I want domain helpers (npm, GitHub, project) to be reusable, so that future scripts can leverage the same building blocks

## Implementation Decisions

### Architecture: two scripts + one skill

- **`deprecate-prepare <project-name>`**: idempotent info-gathering. Resolves the project across projects.jsonc, GitHub, npm, and disk. Clones to `/tmp/oroshi/deprecate/<name>/` if the repo isn't on disk and the owner is `pixelastic`. Returns JSON with full state.
- **`deprecate-end <project-name>`**: calls `deprecate-prepare` internally to get state, then executes all steps idempotently with fail-fast. Returns `{"status":"ok"}` or `{"status":"error","step":"...","message":"..."}`.
- **`/deprecate` skill**: orchestrates the flow — calls prepare, asks for reason, rewrites it, writes README, confirms plan, calls end.

### `deprecate-prepare` lookup flow

1. Check projects.jsonc via `project-exists` / `project-path` → if found, check disk, read git remote for owner/repo
2. If not in projects.jsonc → try `gh repo view pixelastic/<name>`
3. If not on GitHub → `status: "not-found"`
4. If on disk: use that path. If not on disk but in `/tmp/oroshi/deprecate/<name>/`: use that. Otherwise: clone there (only if owner is `pixelastic`).
5. Read npm package name from disk via `yarn-package-name`, check `npm-is-published`, `npm-is-deprecated`, `npm-is-logged-in`

### `deprecate-prepare` JSON output

```json
{
  "status": "ok | not-found",
  "projectName": "callirhoe",
  "inProjectsJsonc": true,
  "github": {
    "owner": "pixelastic",
    "repo": "callirhoe",
    "description": "~ Simplified API to my most used SaaS services",
    "isArchived": false
  },
  "clonedAt": "/home/tim/local/www/projects/callirhoe",
  "npmPackage": "callirhoe",
  "npmIsDeprecated": false,
  "npmIsLoggedIn": false
}
```

- `github`: `null` if not found on GitHub
- `npmPackage`: `null` if no package.json, private, or not published
- `npmIsDeprecated` and `npmIsLoggedIn`: only present if `npmPackage` is not null

### `deprecate-end` steps (idempotent, fail-fast)

1. Call `deprecate-prepare` to get state
2. If GitHub repo exists and not archived:
   a. Disable Renovate: if `.github/renovate.json` exists, overwrite with `{"enabled": false}`
   b. Commit + push: only if there are uncommitted changes. Message: `DEPRECATED: <name> is now deprecated and archived`
   c. Update description: prefix `[DEPRECATED] ` if not already prefixed
   d. Archive repo via `git-github-repo-archive`
3. If npm package exists and not deprecated:
   a. Check `npm-is-logged-in`, fail if not
   b. `npm-deprecate` with message: `No longer maintained. See https://github.com/<owner>/<repo> for details.`
4. If in projects.jsonc:
   a. `project-remove` (uses `jsonc-remove-key` internally)
   b. `projects-build`
5. Return `{"status": "ok"}`

### Skill flow

1. Run `deprecate-prepare <name>`, parse JSON
2. If `status: "not-found"` → tell user, stop
3. If npm package exists but not logged in → warn user, stop
4. Ask user for deprecation reason, rewrite to proper English
5. Show plan (what will be done), user confirms
6. Read existing README from `clonedAt`, prepend deprecation notice:
   ```
   > **⚠️ ARCHIVED**: <reason>

   ---

   <original README>
   ```
7. Run `deprecate-end <name>`
8. Report result

### GitHub org detection

- If repo is cloned on disk: read owner/repo from `git remote get-url origin`
- If not on disk: default to `pixelastic/<name>`
- Only clone repos owned by `pixelastic` (user has push rights)

### New domain helpers

**npm domain** (new, in `tools/term/zsh/config/functions/autoload/npm/`):
- `npm-is-published` — check if package exists on npm registry
- `npm-is-deprecated` — check if package is deprecated on registry (parses JSON)
- `npm-is-logged-in` — wraps `npm whoami`
- `npm-login` — wraps `npm login`
- `npm-deprecate` — wraps `npm deprecate`

**GitHub domain** (extend existing `git-github-*`):
- `git-github-repo-is-archived` — check `isArchived` via `gh api`
- `git-github-repo-description` — get description via `gh api`
- `git-github-repo-description-set` — update description via `gh api -X PATCH`
- `git-github-repo-archive` — archive via `gh repo archive`

**Project domain** (extend existing `project-*`):
- `project-remove` — remove entry from projects.jsonc via `jsonc-remove-key`

**JSON domain** (new Node.js tool):
- `jsonc-remove-key` — remove a top-level key from a JSONC file preserving comments. Node.js script using `jsonc-parser` npm package. Installed as dependency in root `package.json`.

### Scripts location

- `deprecate-prepare` and `deprecate-end` in `scripts/bin/ai/deprecate/`
- npm helpers in `tools/term/zsh/config/functions/autoload/npm/`
- GitHub helpers in `tools/term/zsh/config/functions/autoload/git/github/`
- `project-remove` in `tools/term/zsh/config/functions/autoload/project/`
- `jsonc-remove-key` in `tools/_languages/json/`
- Skill in `tools/ai/claude/config/skills/deprecate/SKILL.md`

## Testing Decisions

### Test philosophy

- Test modules with real logic (parsing, file modification, orchestration)
- Don't test thin CLI wrappers where the test would just assert the mock was called
- All tests mock external APIs — never hit real GitHub, npm, or git remotes
- Use `bats_mock` for mocking external commands in bats tests

### Modules with tests

- **`npm-is-deprecated`**: parses `npm view` JSON output to detect deprecation status. Mock `npm view` response, verify correct parsing of deprecated vs non-deprecated packages.
- **`project-remove`**: modifies projects.jsonc via `jsonc-remove-key`. Test with a fixture JSONC file, verify entry is removed and comments are preserved.
- **`jsonc-remove-key`**: Node.js script with real parsing logic. Test with JSONC fixtures containing comments, verify key removal preserves surrounding comments and formatting.
- **`deprecate-prepare`**: orchestrator with lookup flow and conditional clone logic. Mock all domain helpers, test the various paths (in projects.jsonc, not in projects.jsonc, not on GitHub, already cloned, npm exists, etc.).
- **`deprecate-end`**: orchestrator with idempotency logic. Mock `deprecate-prepare` and all domain helpers, test skip-if-done behavior for each step, test fail-fast on errors, test resume after failure.

### Prior art

- Bats tests in `tools/term/zsh/config/functions/autoload/json/__tests__/jsonc2json.bats`
- Bats tests in `tools/term/zsh/config/functions/autoload/project/__tests__/projects-build.bats`
- JS tests via `yarn run test` for Node.js scripts

## Out of Scope

- Full deletion of repos (user handles this manually from GitHub UI)
- Deprecating projects not on GitHub
- Auto-login to npm (user runs `npm-login` manually)
- Batch deprecation of multiple projects in one invocation
- Unarchiving / undeprecating projects
- Scanning all possible Renovate config locations (only `.github/renovate.json`)

## Further Notes

- A glossary pass (`/glossary`) should be done after implementation to document the domain prefixes: `yarn-package`, `yarn-dependency`, `node-module`, `npm`, `git-github`, `project`.
- The `jsonc-parser` npm dependency must be added to the root `package.json` of oroshi.
- GitHub token scopes (`gist`, `read:org`, `repo`) are sufficient for all GitHub operations. npm requires a separate `npm login`.
