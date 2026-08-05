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
1. Check if called from non-ZSH context
2. Migrate to autoloaded function or justify as script
3. Ensure doc comment present
4. Update aliases and references

## Acceptance criteria

- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
