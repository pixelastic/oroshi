## Issue 03 — git-file-lint JS branch

### Spec: `displayLintErrors` not used
```zsh
if [[ $hasJsFiles == "1" ]]; then
  local jsOutput="$(yarn run lint:fix --js ${jsFiles[@]} 2>&1)"
  if [[ "$jsOutput" != "" ]]; then
    hasViolations="1"
    echo "── JS ──"
    printf '%s\n' "$jsOutput"
  fi
fi
```
**Problem:** Spec says to call `displayLintErrors "JS" "$(yarn run lint:fix --js ${jsFiles[@]})"`.
**Reason skipped:** `displayLintErrors` is JSON-only (checks for `"[]"`, pipes through `jq`). Aberlaas outputs plain-text ESLint stylish format to **stderr**, not stdout. The spec's suggested call would never detect errors (stderr not captured by `$()`). Inline implementation is correct.

### Spec: `2>&1` not in spec
**Problem:** Spec's suggested call has no `2>&1`; the diff adds it.
**Reason skipped:** Necessary — aberlaas writes errors to stderr. Without `2>&1`, `$()` captures empty string even on failure and no errors would ever be shown.

### Standards: `lint:fix` mutates files
**Problem:** `lint:fix` auto-fixes files in place; ZSH/BATS linters are read-only.
**Reason skipped:** Matches the `lintstaged.config.js` intent for JS files (`'**/*.js': ['yarn run lint:fix --js', ...]`). Auto-fix behavior is intentional for this project's pre-commit workflow.
