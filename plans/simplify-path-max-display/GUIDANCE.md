## Guidance

**Function under change**: `simplify-path` (autoload, misc functions folder)
**Test file**: `__tests__/simplify-path.bats` (same folder)

**Testing command**: `bats <filepath>`
**Linting command**: `zshlint <filepath>`

**Test helper**: tests use `bats_run_function` from the shared bats helper library. See existing tests in the same `__tests__/` folder for prior art.

**Truncation formula** (from PRD):
- `left = ⌊(maxDisplay - 1) / 2⌋` — integer division, no floats
- `right = maxDisplay - 1 - left`
- Output order: `inputPathArray[1..left]` + `…` + `inputPathArray[(-right)..-1]`

**Clamping rule**: if `maxDisplay < 4`, silently set to 4 before computation.

**No callers need updating**: all existing callers (`path.zsh`, `fzf-fs-shared-source`, `fzf-fs-shared-preview-header`, `fzf-prompt-directory`, `statusline.lua`) use the default and are unaffected.

**ZSH conventions**:
- Use `local var="$(cmd)"` + manual guard (never split `local`/assignment)
- Use `[[ $isXxx == "1" ]]` for flag booleans, not `(( isXxx ))`
- Use `if/then/fi` for 2+ instruction blocks; `&&` only for single-action one-liners
- `setopt local_options errexit` for autoload functions (no `set -e`)

## Discoveries

### Issue 01 — maxDisplay symmetric truncation
- `$array[1,$n]` ZSH range syntax est la forme correcte pour slicer un array. zshlint avait un faux positif (code 2054) qui a été corrigé — utiliser cette syntaxe sans workaround.
- Home-substitution test must use a long enough path to actually trigger truncation; `$HOME/a/b/c/d` (5 segments) truncates to `~/…/c/d` with default maxDisplay=4.
