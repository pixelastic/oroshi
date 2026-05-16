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
