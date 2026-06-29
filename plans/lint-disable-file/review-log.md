## Issue 01 — disable-file filter

### locals declared inside for loop body

```zsh
for fileLine in "${(@f)fileContentCache[$sourceFile]}"; do
  [[ ! "$fileLine" =~ "..." ]] && continue
  local existing="${fileDisabledRules[$sourceFile]}"
  fileDisabledRules[$sourceFile]="..."
done
```

**Problem:** Reviewer flagged `local fileLine` and `local existing` as declared inside a loop body, suggesting they be hoisted.
**Reason skipped:** The existing (unchanged) code already declares `local -a fields`, `local sourceFile`, `local ruleCode`, `local lineNumber`, etc. inside the same outer for loop. Hoisting would be a codebase-wide style change, not scoped to this issue.

### if+for nesting flagged as "return early" violation

```zsh
if [[ "${fileContentCache[$sourceFile]}" == "" ]]; then
  fileContentCache[$sourceFile]="$(<"$sourceFile")"
  for fileLine in ...; do
    ...
  done
fi
```

**Problem:** Reviewer flagged the nested if+for as violating "return early — no avoidable nesting."
**Reason skipped:** The if block guards a two-step atomic operation (populate cache + scan lines). There is no early-return equivalent that avoids this structure without restructuring the entire loop. The nesting is necessary.
