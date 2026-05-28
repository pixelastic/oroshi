## Session 2026-05-28 — 10: issue-template-reference
- Completed: updated `references/issues-XX-slug.md` — added TLDR line, removed `## PRD` and `## Blocked by` sections, updated title to `XX-slug.md`, documented `issues/XX-slug.md` path and state.json for blockers; deleted `references/prd-json.md`
- Tests added: none (pure doc change)
- Discovered: none
- Fixed: none unplanned
- Skipped feedback: `issue-XXX-slug.md` deletion not in diff — already done in prior session (shown as `D` in git status); reference file rename to bare `XX-slug.md` — spec refers to template content convention, not the reference file's own name
- Next: issue 11 (to-issues-skill-md) — now unblocked (08, 09, 10 all done)

## Session 2026-05-28 — 09: guidance-md-reference
- Completed: created `references/guidance-md.md` (Guidance + Discoveries sections); removed `references/progress-md.md`; updated SKILL.md (exit criterion, link, checklist) to fix dead references
- Tests added: none (pure doc change)
- Discovered: SKILL.md had 3 stale references to `progress-md.md`/`progress.md` — fixed as part of review feedback
- Fixed: SKILL.md dead link + exit criterion + checklist item
- Skipped feedback: `issues.json`→`state.json` link in SKILL.md line 72 — pre-existing, scoped to issue 11
- Next: issue 10 (issue-template-reference) — unblocks 11 → 12

## Session 2026-05-28 — 08: state-json-reference
- Completed: created `references/state-json.md` with new schema (id, issue, done, blocked_by, recap); removed `references/issues-json.md`; example JSON shows both `done: true` (with recap) and `done: false` entries
- Tests added: none (pure doc change, no executable code path)
- Discovered: none
- Fixed: added `done: true` + `recap` example to JSON block after review flagged it as missing
- Skipped feedback: docs naming convention (`__docs/NAME.md`) — dismissed; `references/` is the established folder pattern for this skill
- Next: issue 09 (guidance-md-reference) or issue 10 (issue-template-reference) — both unblock 11 → 12

## Session 2026-05-28 — 07: prd-end

- Completed: updated `prd-end` — changed `prdPath` from `ralph/$slug/PRD.md` to `plans/$slug/PRD.md`; updated both inline comments (line 3 + `Output:` line) to match
- Tests added: `prd-end.bats` — 4 tests (prdPath correct, no ralph/ ref, exit 1 on missing branch, worktreePath+branch fields)
- Discovered: stale `Output:` comment on line 5 also referenced `ralph/` — fixed as part of same PR
- Fixed: none unplanned
- Skipped feedback: bats_mock pattern flagged by standards agent as PATH-stub violation — dismissed; bats_mock uses zsh function overriding, not PATH, and is the established codebase pattern (same as ralph.bats); duplicate comment in spec agent diff — artifact of malformed diff display, actual file is clean
- Next: issue 08 (state-json-reference: create references/state-json.md in to-issues skill), issue 13 (prompt-update: call plans-progress)

## Session 2026-05-28 — 06: ralph-script

- Completed: updated `ralph.bats` — replaced `prd.json` fixtures with `state.json`; replaced trivial `.ralph-state.json` absence checks with meaningful `ralph.json` create+clear assertions (claude mock verifies `ralph.json` exists during run); fixed 3 `noSplitLocal` violations; quoted `'done'` arg
- Tests added: tests 4 and 5 renamed + strengthened (were "clears state file", now "creates ralph.json during run and clears it after"); inline claude mock assertions added
- Discovered: `ralph` script never called `ralph-directory` — the spec assumption was wrong; no script changes needed
- Fixed: none unplanned
- Skipped feedback: spec agent flagged missing `plans-directory` call in `ralph` script — dismissed; script never called `ralph-directory`, the spec was stale; `prd.json`→`state.json` flagged as out-of-scope — dismissed, issue explicitly says "update bats tests if they reference old file names"
- Next: issue 07 (prd-end: update output path from ralph/ to plans/) or issue 08 (state-json-reference: update references)

## Session 2026-05-28 — 04: ralph-start

- Completed: created `ralph-start` script; reads `state.json`, finds first eligible issue (not done, all blockers done, sorted by id), outputs JSON with `status:"next"` + issue + absolute paths; outputs `{"status":"done"}` when all complete; exits 1 on deadlock or missing state.json
- Tests added: `ralph-start.bats` — 10 tests covering next/done/deadlock/missing/malformed/out-of-order/path-resolution/absolute-paths
- Discovered: spec says "by id" → `sort_by(.id)` required; spec says "error message" on deadlock → added print to stderr
- Fixed: none unplanned
- Skipped feedback: `local` at top-level flagged by standards agent — established codebase pattern (same in `plans-progress`, `ralph-end`); `return` vs `exit` — same; truncated diff artifact in spec agent — actual file correct; empty array edge case — out of spec scope
- Next: issue 06 (ralph-script: update to use plans-directory) or issue 13 (prompt-update: call plans-progress)

## Session 2026-05-28 — 05: ralph-end

- Completed: updated `ralph-end.bats` — replaced `prd.json` fixtures with `state.json` (new format); quoted `'done'` arg to suppress zshlint keyword warning; renamed tests 4 and 5 from "prd.json" to "state.json"; added test 6 "does not modify state.json"
- Tests added: `does not modify state.json` (new); 5 existing tests updated
- Discovered: implementation was already correct (done in session 02); only test fixtures needed updating
- Fixed: pre-existing zshlint warning on `done` keyword — fixed by quoting `'done'`; noSplitLocal on new test — fixed by combining local+assignment
- Skipped feedback: `local before="$(cat ...)"` flagged by both review agents — dismissed; `local var="$(cmd)"` is the established bats pattern in plans-directory.bats and plans-progress.bats
- Next: issue 04 (ralph-start: update to use new file layout) or issue 06 (ralph-script: update to use plans-directory/state.json)

## Session 2026-05-28 — 02: plans-progress

- Completed: created `plans-progress` (reads `state.json`, counts `.done == true`); deleted `ralph-progress` and `ralph-progress.bats`; updated `ralph-end` and `git.zsh` call sites; renamed prompt function `git_issues_prd` → `git_issues_plan` in `git.zsh`, `git.bats`, `index.zsh`
- Tests added: `plans-progress.bats` (8 tests covering mixed/all-true/all-false/empty/malformed/missing/no-arg)
- Discovered: `git.zsh` and `ralph-end` both referenced `ralph-progress` — updated both
- Fixed: none unplanned
- Skipped feedback: `return` vs `exit` — codebase uses `return` everywhere (bats sources scripts); `local` at top-level — established codebase pattern; `done` variable name — same as original, codebase pattern; test fixture mismatch reported by spec agent was artifact of malformed diff sent to reviewer, actual file was correct
- Next: issue 05 (ralph-end: update to read state.json for prd_done) — now unblocked (02 and 03 done)

## Session 2026-05-28 — 03: ralph-json

- Completed: `ralph-state` now reads/writes `ralph.json` instead of `.ralph-state.json`; `.gitignore` updated; pre-existing `noDashZ` lint violations fixed
- Tests added: updated all 5 filename assertions; added `[ -f "$DIR/ralph.json" ]` guards to `get` and `clear` tests
- Discovered: 3 pre-existing zshlint `noDashZ` violations on modified lines — fixed as part of required lint-clean pass
- Fixed: none unplanned
- Skipped feedback: spec agent flagged unanchored `ralph.json` in `.gitignore` as too broad — intentional, old entry was also unanchored and ralph.json is created in subdirs
- Next: issue 02 (plans-progress: rename `ralph-progress` → `plans-progress`) — unblocked, unblocks 05 and 13

## Session 2026-05-28 — 01: plans-directory

- Completed: renamed `ralph-directory` → `plans-directory` (output now `plans/$slug/`); updated `git-worktree-is-ralph` to check `plans/<slug>/state.json`; updated bats tests for both; updated `ralph-progress` call site and its deduction test
- Tests added: `plans-directory.bats` (4 tests); updated `git-worktree-is-ralph.bats` (2 tests); updated `ralph-progress.bats` (1 test)
- Discovered: `ralph-progress` calls `ralph-directory` → needed a minimal fixup to `plans-directory`; also needed `state.json` in its worktree deduction test
- Fixed: `ralph-progress` call site updated to `plans-directory`; guards + comment added to `plans-directory` after review
- Skipped feedback: spec agent flagged `ralph-progress` still reads `issues.json` (not `state.json`) — out of scope, covered by issue 06
- Next: issue 03 (ralph-json: rename `.ralph-state.json` → `ralph.json`) — unblocked, unblocks 05 and 06
