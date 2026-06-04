## Issue 01 — Rename core and tests

### Modules D/E/F not implemented
**Problem:** Reviewer flagged callers (`git-file-lint`, `lint-zsh`), NeoVim config, and Claude/AI config as absent from the diff.
**Reason skipped:** These are explicitly scoped to issue 02 and later issues per the PRD.

### bats-test-path.bats not updated
```
# Referenced in PRD acceptance criteria
```
**Problem:** Reviewer flagged `bats-test-path.bats` path fixture not updated.
**Reason skipped:** File does not exist in this repo — the acceptance criterion was inapplicable.
