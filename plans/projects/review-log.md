## Issue 02 — Migrate project-exists

### Bats mock pattern deviates from spec description

```bats
@test "known project with icon: returns exit 0" {
  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[aberlaas:icon]="  "
  }
  bats_mock projects-load-definitions
  bats_run_function project-exists "aberlaas"
  [ "$status" -eq 0 ]
}
```

**Problem:** Spec says "mock `projects-load-definitions` as a no-op, populate `PROJECTS_V2` directly in each test". The implementation instead populates PROJECTS_V2 inside the mock body and re-mocks per test.

**Reason skipped:** ZSH associative arrays can't cross `bats_run_function`'s subshell boundary — direct pre-call assignment doesn't work. The mock-body pattern matches what context-badge.bats and project-name.bats do throughout the codebase and is the only approach that works.

---

## Issue 03 — Migrate yarn.zsh

### No exit-code guard on `projects-load-definitions`

```zsh
projects-load-definitions

for rawLine in ${(f)linkListRaw}; do
```

**Problem:** Reviewer flagged missing guard — if `projects-load-definitions` fails, the loop runs with empty PROJECTS_V2 silently.

**Reason skipped:** Prompt functions degrade silently by design. If definitions fail, the existing fallback (chain icon ` `) is shown via `displayedLinkCount != totalLinkCount` logic. Adding `|| return` would hide the segment entirely, which is worse. No other helper call in the function is guarded either.

## Issue 06 — Rewrite context-path.bats

### `bats_tmp_dir` called but seemingly unused
~~**Problem:** Reviewer flagged `$BATS_TMP_DIR` as never referenced in the file.~~
~~**Reason skipped:** `bats_mock` writes to `$BATS_TMP_DIR/mock.zsh` internally.~~
**Resolved:** `bats_mock` now auto-initializes `$BATS_TMP_DIR` if unset (guard added to helper). The explicit `bats_tmp_dir` call was removed from `context-path.bats`.

### Shared `context-root` mock should move to `setup`
```bats
@test "path inside project: ..." {
  context-root() { echo "/my/root"; }
  bats_mock context-root
  ...
}
@test "path at project root: ..." {
  context-root() { echo "/my/root"; }
  bats_mock context-root
  ...
}
@test "path outside all known projects: ..." {
  context-root() { echo ""; }
  bats_mock context-root
  ...
}
```
**Problem:** Reviewer flagged that two tests share the same mock body and should be moved to `setup`.
**Reason skipped:** Mock body varies across tests (`/my/root` vs `""`). Per `context-root.bats` prior art, per-test-varying mocks belong in the test body.

### `PROJECTS_V2` not populated in tests
**Problem:** Spec mentions populating `PROJECTS_V2` inside each test.
**Reason skipped:** `context-path` never reads `PROJECTS_V2` directly — it delegates to `context-root`, which is mocked. Population is irrelevant and would add noise.

## Issue 08 — Migrate Kitty Python

### camelCase naming violates PEP 8

```python
for projectName, project in rawProjectData.items():
    bgInactive = project.get("backgroundInactive", {}).get("ansi")
```

**Problem:** PEP 8 requires `snake_case` for variables. `projectName`, `bgInactive`, `rawProjectData`, `getCursorColor`, `initProjectList`, etc. all use camelCase.

**Reason skipped:** camelCase is a pervasive pre-existing convention throughout this file (`getCursorColor`, `getProjectData`, `initProjectList`, `projectState`, `rawProjectData`). Fixing only the new variables would create inconsistency; fixing all would be an unrelated refactor out of scope for this issue.

## Issue 10 — Rename PROJECTS_V2 to PROJECTS

### CONTEXT.md wording omits `projects-load-definitions`

```md
Defined in `theming/src/projects.json`; loaded into the `PROJECTS` associative array via `theming/dist/projects.zsh`.
```

**Problem:** Reviewer suggested the text should also mention `projects-load-definitions` as the loading mechanism, since `dist/projects.zsh` is sourced *by* `projects-load-definitions`, not used directly.

**Reason skipped:** Spec criterion says "references `dist/projects.zsh` and the `PROJECTS` associative array" — both present. `projects-load-definitions` is an implementation detail; the glossary entry describes the data model, not the load sequence.

### `projects-build.bats` — pre-existing broken test path

```bats
PROJECTS_BUILD="$(realpath "${BATS_TEST_DIRNAME}/../projects-build")"
```

**Problem:** `BATS_TEST_DIRNAME` resolves to `theming/src/__tests__`; `../projects-build` = `theming/src/projects-build` (doesn't exist). Correct path should be `../../projects-build`. All 5 tests in this file fail with exit 127.

**Reason skipped:** Pre-existing failure confirmed via stash test — broken before issue 10 changes. Out of scope for this rename issue.
