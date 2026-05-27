## Problem Statement

The `reorg` worktree is 19 commits ahead and 61 commits behind `main`. The reorg branch moved ~1 300 files from `config/`, `scripts/install/`, `scripts/deploy/` into `tools/`. Meanwhile main added new features and bugfixes on the old paths. A naive `git rebase main` would replay each of the 17 migration commits one by one, triggering "modify/delete" conflicts on every file that main touched and reorg moved — 59 files spread across 17 rebase steps.

## Solution

Use `git merge main` instead of rebase. Git's 3-way merge with rename detection resolves the move-only cases automatically and limits manual work to files where both branches modified content.

After the merge, a follow-up commit migrates the files that main added at old `config/` paths (which reorg had already cleared) to their correct `tools/` locations.

## Analysis

**59 files** changed in both branches (main modified, reorg renamed):

| Similarity | Count | Strategy |
|---|---|---|
| R100 (move only) | 49 | auto-resolved by rename detection |
| R<100 (move + content change) | 10 | manual 3-way merge |

**34 files** added by main at old paths (no conflict, but need follow-up):

| Location | Count | Action |
|---|---|---|
| `config/ai/claude/...` | 8 | migrate to `tools/ai/claude/config/...` |
| `config/term/zsh/...` | 14 | migrate to `tools/term/zsh/config/...` |
| `scripts/bin/...` | 12 | already in scope, stay in place |

## Implementation Decisions

- **Merge, not rebase** — rebase would hit conflicts at each of the 17 migration commits; merge does it in one shot.
- **No squash** — preserve the 19 reorg commits in history; the merge commit links both lineages.
- **Rename detection threshold** — use git default (50%); all 59 conflicting files are above that.
- **Follow-up commit for orphans** — new `config/` files from main get moved to `tools/` in a dedicated commit after the merge is clean, so conflict resolution and migration stay separate.
- **scripts/bin/ stays** — per the original reorg PRD, `scripts/bin/` is out of scope and remains untouched.

## Out of Scope

- Rebasing the result onto main (separate step, after this merge is stable)
- Migrating any scripts/bin/ files to tools/
- Any further reorg work beyond what main introduced
