## Issue 04 — yarn-link monorepo detection
### Monorepo detection unreachable under Yarn Classic
```zsh
if [[ $yarnIsBerry == "0" ]]; then
    local moduleName="$(yarn-package-name "$modulePath")"
    yarn-link-classic-create $modulePath
    yarn-link-classic-enable $moduleName
    continue
fi
```
**Problem:** The `yarn-is-monorepo` check runs after the Classic early-continue, so Classic users with a monorepo path skip workspace expansion.
**Reason skipped:** Out of scope — the spec targets Berry (aberlaas uses Berry). Classic monorepo support is not a current use case.
