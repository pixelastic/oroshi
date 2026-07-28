## Guidance

- Test helpers: `bats <filepath>`
- Lint bats: `bats-lint <filepath>`
- Bats helper directory: `tools/term/bats/config/`
- Bats helper tests: `tools/term/bats/config/__tests__/`
- Bats-lint rules: `scripts/bin/term/bats/bats-lint/__rules/`
- Bats-lint rule tests: `scripts/bin/term/bats/bats-lint/__rules/__tests__/`
- Bats-lint wiring: `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`
- Prior art for helpers: `helper.bats` (tests `bats_cleanup`, mocking)
- Prior art for rules: `rule-no-single-bracket.zsh` and its test file
- The `helper` file sources sub-helpers — add `source` line at the end
- Rule output format: `file▮code▮error▮line▮message` (▮ = `$_SEP`)
- Use `/zsh-writer` skill when writing ZSH code

## Discoveries

### Issue 02 — noInlineJqAssertion lint rule
- Null-check heuristic must verify absence of `jq -r` — with `-r`, `"null"` is a raw string, not a JSON null
- Rule test files that contain flaggable patterns need `# bats-lint disable=noInlineJqAssertion` above those lines
