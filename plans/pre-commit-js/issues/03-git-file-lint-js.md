## TLDR

Extend `git-file-lint` to lint dirty JS files using `is-js` and `yarn run lint:fix --js`.

## What to build

Add a JS branch to `git-file-lint` (`tools/term/zsh/config/functions/autoload/git/file/git-file-lint`), mirroring the existing ZSH and BATS branches:

- Accumulate dirty JS files in a `jsFiles` array using `is-js`
- After the loop, if `hasJsFiles == "1"`, call `displayLintErrors "JS" "$(yarn run lint:fix --js ${jsFiles[@]})"`
- Yarn resolves the repo root automatically — no `cd` needed

## Behavioral Tests

None — integration-level change.

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] `git-file-lint` processes dirty `.js` files through ESLint
- [ ] JS lint errors are displayed under a `── JS ──` header
- [ ] Non-JS dirty files are unaffected
- [ ] `hasViolations` is set correctly when JS lint fails, causing a non-zero exit
