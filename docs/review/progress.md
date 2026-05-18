## Execution order

issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → needs issue-001
issue-004 → needs issue-001
issue-005 → needs issue-001 + issue-002 + issue-003 + issue-004 (HITL — Tim must approve SKILL.md wording)
issue-006 → needs issue-001 + issue-002 + issue-003 + issue-004 + issue-005

## Guidance

- Script location: `scripts/bin/ai/review-diff` (alongside `scripts/bin/ai/review`)
- Tests location: `scripts/bin/__tests__/review-diff.bats`
- Follow the `git-worktree-list.bats` setup/teardown pattern (bats_tmp helper, real git repo per test)
- Use `run_zsh_fn` from `helper.bash` to call zsh functions in bats
- Branch detection: `git-branch-exists <arg>` — exit 0 → branch, non-zero → SHA
- Parent branch: `git-branch-parent` — used for self-review base
- rtk scope: all output-producing git calls go through `rtk`; detection/enumeration calls do not
- Output format: raw concatenation, no section headers; log + stat + full diff per case
- issue-005 is HITL: write the SKILL.md update, then stop and wait for Tim to review before proceeding to issue-006

---
## Log (append below when an issue is completed)

## Session 2026-05-16 — issue-001: review-diff 0-arg case
- Completed: created `scripts/bin/ai/review-diff` (executable zsh script) + `scripts/bin/__tests__/review-diff.bats` with 4 passing tests
- Tests added: clean tree exits 0, modified tracked file, untracked file new-file block, staged file hunk
- Discovered: `rtk git diff` reformats output and strips `diff --git` headers — used `rtk proxy git diff` instead to preserve raw format while still routing through rtk
- Fixed: post-session refactor — `git rev-parse --show-toplevel` → `git-directory-root` helper; `repoRoot` moved after early return; multi-line format for `rtk proxy` call; inline comments added
- Skipped feedback: (1) staged-new-file 5th test — reviewer reconsidered; `git diff HEAD` handles it correctly, no bug exists; (2) untracked directory edge case — out of scope for issue-001
- Next: issue-002 (1-arg branch: self-review and external review)

## Session 2026-05-17 — issue-002: review-diff 1-arg branch case
- Completed: added 1-arg branch handling to `scripts/bin/ai/review-diff`; two new bats tests in `review-diff.bats`
- Tests added: self-review (arg == current branch, diffs parent..HEAD), external review (arg != current branch, diffs HEAD..branch; main-only commits absent)
- Discovered: none
- Fixed: post-review — `setopt local_options errexit` → `set -e` (shebang scripts use set -e per convention); removed `local` from all script-level variable declarations (no-op outside functions)
- Skipped feedback: (1) missing `git_env_clean` in setup() — not applicable; helper.bash already unsets GIT_DIR etc. at load time, matching all other bats files in the project; (2) raw `git` calls (items 4–5) — pre-existing issue-001 code, already accepted
- Next: issue-003 (1-arg commit SHA)

## Session 2026-05-19 — issue-003: review-diff 1-arg SHA case
- Completed: added 1-arg SHA handling to `scripts/bin/ai/review-diff`; one new bats test in `review-diff.bats`
- Tests added: 1-arg SHA: stdout contains the commit message and a diff --git line
- Discovered: none
- Fixed: post-review — split `local mainBranch` in external-review test (issue-002 carryover) merged into single-line assignment
- Skipped feedback: (1) `return 0` vs `exit 0` at top-level — pre-existing pattern, accepted in prior sessions; (2) partial diff cleanliness check in external-review test — out of scope for issue-003; (3) prd.json items 0003/0004 flagged as unimplemented — reviewer read pre-implementation state; 0003 is now done
- Next: issue-004 (2-arg range)
