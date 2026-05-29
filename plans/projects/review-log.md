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
