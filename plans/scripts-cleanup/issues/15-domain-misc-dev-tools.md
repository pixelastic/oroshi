## TLDR

Clean up misc dev tools: rewrite, migrate, document. Covers small domains and standalone dev-oriented scripts.

## What to build

Scripts in scope (~15):
- `fork` — run command in background with lockfile
- `install-deb` — install .deb package
- `is-older` — check if file is older than N minutes (rename per map)
- `css-fix` — fix CSS file
- `python-version` (Bash → ZSH rewrite)
- `node-module-install` — globally install a node binary
- `colorize-bin` — wrapper around colorize (evaluate if needs to be script)
- `algolia-download` → rename per map (algolia-index-download)
- `version-compare` (Ruby → ZSH rewrite, rename per map)
- `lua-lint-selene` — wrap selene linter
- `lua-test-path` — find spec file for Lua file
- `plan-badge` — render plan progress badge
- `ralph-is-running` — check if Ralph session active
- `review-blog-start` — upload markdown to Google Docs
- `bats-fixture-script-foo/bar/baz` — test fixtures (keep as scripts, they're fixtures)

For each script:
1. Rewrite from Ruby/Bash to ZSH if needed
2. Apply renames from rename map (issue 02)
3. Check if called from non-ZSH context
4. Migrate to autoloaded function or justify as script
5. Ensure doc comment present
6. Update aliases and references

## Acceptance criteria

- [ ] All Ruby/Bash scripts rewritten to ZSH
- [ ] Renames applied per rename map
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
