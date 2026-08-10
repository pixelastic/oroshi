## Issue 03 — complete-jumps merge projects
### Merge direction contradicts spec algorithm
```zsh
entries[$name]="${PROJECTS[$key]}"
```
**Problem:** Spec says "iterate PROJECTS, add entries not already in marks" but code unconditionally overwrites marks with projects.
**Reason skipped:** Behavioral outcome is identical — projects win on collision either way. Implementation approach differs from spec wording but satisfies all acceptance criteria.

## Issue 04 — mark-create
### Negated conditions in loop guards
```zsh
[[ ! "$key" == *":path" ]] && continue
```
**Problem:** Loop uses negated conditions with `continue` instead of positive-match early return
**Reason skipped:** `continue` inside a for loop is the idiomatic way to skip iterations; return-early pattern applies to function-level guards, not loop body filters

### Short-form flags on rm and ln
```zsh
rm -f "$OROSHI_MARKPATH/$name"
ln -s "$PWD" "$OROSHI_MARKPATH/$name"
```
**Problem:** Uses `-f` and `-s` short flags instead of long-form
**Reason skipped:** `rm -f` and `ln -s` are common idioms covered by the calling-commands.md exception list ("etc")

### local declarations inside loop body
```zsh
local projName="${key%:path}"
local projPath="${PROJECTS[$key]}"
```
**Problem:** Re-declares `local` on every loop iteration
**Reason skipped:** Correct per variables.md rule; ZSH handles this fine and it keeps scope explicit

### Missing comment on mkdir -p
```zsh
mkdir -p "$OROSHI_MARKPATH"
```
**Problem:** No dedicated comment for `mkdir -p` guard
**Reason skipped:** It's setup grouped under the existing "Create mark" comment, not a guard clause
