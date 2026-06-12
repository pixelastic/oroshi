## Guidance

- Lint-staged config: `lintstaged.config.js` at the repo root
- `is-js`, `is-bats`, `is-zsh` live in `tools/term/zsh/config/functions/autoload/term/`
- `git-file-lint` and `git-file-test` live in `tools/term/zsh/config/functions/autoload/git/file/`
- BATS tests for autoload functions live in `__tests__/` next to the function
- Prior art for `is-js` tests: `is-bats` and `is-zsh` test suites
- Testing zsh: `bats <filepath>`
- Linting zsh: `zsh-lint <filepath>`
- Linting js: `yarn run lint:fix <filepath>`
- `yarn run` resolves repo root automatically — no `cd` needed before calling it

## Discoveries

### Issue 03 — git-file-lint JS branch
- `displayLintErrors` is JSON-only (checks for `"[]"`, pipes through `jq`) — cannot be reused for JS; aberlaas outputs plain-text ESLint stylish format to **stderr**
- `yarn run lint:fix --js files...` requires `2>&1` to capture errors; without it `$()` captures nothing (errors go to stderr) and the inline check would never detect failures
- `yarn run lint:fix` (with fix) is intentional — matches the lintstaged config behavior; not a bug
- `local var="$(cmd)"` with `err_return`: `local` always returns 0, so err_return doesn't trigger; use non-empty output as the error signal instead of exit code
