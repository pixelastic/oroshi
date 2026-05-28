## TLDR

Update the zsh prompt to call `plans-progress` instead of `ralph-progress`.

## What to build

Update `tools/term/zsh/config/prompt/git.zsh` function `oroshi-prompt-populate:git_issues_plan` (renamed from `git_issues_prd`) to call `plans-progress` instead of `ralph-progress`. No other logic changes — the output format is identical.

## Acceptance criteria

- [ ] Prompt function calls `plans-progress` instead of `ralph-progress`
- [ ] Prompt still displays `done/total` in the correct color
- [ ] No references to `ralph-progress` remain in prompt code
