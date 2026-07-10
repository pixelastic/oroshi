## TLDR

Add `--repo-dir` flag to `sidequest` and update the skill to resolve named repos and pass the flag.

## What to build

**Script:** Add an optional `--repo-dir <path>` flag to `sidequest`. When provided, the script `cd`s into that directory before creating the worktree. Two guards are added: the `cd` itself fails fast (via `set -e`) if the path does not exist, and `git-directory-is-repository` is called afterward to emit an explicit error if the directory is not a git repo. Default behavior (no flag = use CWD) is unchanged.

**Skill (`SKILL.md`):** Rename Step 1 to "Gather prerequisites" — it now collects both the slug (from conversation context) and the target repo (if the user mentioned one). To resolve a repo name, Claude normalizes the user's natural language to a project name, calls `project-path <name>`, and uses the returned path as `--repo-dir`. If `project-path` fails, Claude asks for clarification. Step 3 is updated to call `sidequest <filepath> [--repo-dir <path>]`. The checklist and rationalizations are updated to reference `sidequest` instead of `sidequest-end`.

Prior art for tests: existing `sidequest.bats` pattern using `bats_mock` to stub `git-directory-is-repository`.

## Behavioral Tests

**`--repo-dir` with nonexistent path:**
- exits with error

**`--repo-dir` with a non-git directory:**
- exits with error (mock `git-directory-is-repository` → failure)

**`--repo-dir` with a valid git repo:**
- calls `git-worktree-create` with the correct slug (mock `git-directory-is-repository` → success)

## Acceptance criteria

- [ ] `--repo-dir <path>` flag accepted by `sidequest`
- [ ] Nonexistent `--repo-dir` path exits with error
- [ ] Non-git `--repo-dir` path exits with error and descriptive message
- [ ] Valid `--repo-dir` path: worktree created in that repo
- [ ] No `--repo-dir`: behavior unchanged (uses CWD)
- [ ] Bats tests for all three `--repo-dir` cases pass
- [ ] Skill Step 1 renamed "Gather prerequisites"; collects slug + optional repo
- [ ] Skill resolves repo name via `project-path`; asks user if resolution fails
- [ ] Skill Step 3 calls `sidequest <filepath> [--repo-dir <path>]`
- [ ] Skill checklist and rationalizations reference `sidequest` (not `sidequest-end`)
