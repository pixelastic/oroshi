## TLDR

Clean up Ruby/Gem domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (7):
- `bundle-install` — bundle install + rehash rbenv
- `bundle-install-in-progress` — check if bundle install running
- `bundle-update` — bundle update + rehash rbenv
- `gem-install` — gem install + rehash rbenv
- `gem-uninstall` — gem uninstall + rehash rbenv
- `gem-update` — gem update + rehash rbenv
- `has-ruby` — check if Ruby is available

For each script:
1. Migrate to autoloaded function
2. If called from external context, update call site to `bin-zsh <function>`
3. Update aliases and references

## Acceptance criteria

- [ ] All scripts migrated to autoloaded functions
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
