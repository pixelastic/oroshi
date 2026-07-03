## Issue 01 — Colorize fzf-source-files

### Helper-to-helper sourcing outside documented GLOSSARY model

```zsh
source "${0:h}/fzf-colorize-path.zsh"
```

**Problem:** Reviewer flagged that the GLOSSARY documents helpers as sourced *by FZF Scripts*, not by other helpers — helper→helper sourcing is outside the documented model.
**Reason skipped:** GUIDANCE.md explicitly cites `fzf-regexp-common.zsh` as prior art for this exact pattern (`source "${0:h}/fzf-colorize-path.zsh"` at the top of a helper). The model is intentional.

### End-to-end smoke test for `ctrl-shift-p --source`

**Problem:** Spec AC item "`ctrl-shift-p --source` output is visually colorized end-to-end" is untested.
**Reason skipped:** This is a manual visual verification step, not an automatable bats test. It will be validated by the user after commit.
