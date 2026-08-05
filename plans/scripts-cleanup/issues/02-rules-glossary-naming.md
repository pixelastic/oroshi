## TLDR

Define rules for script vs autoloaded function, add glossary entries, and establish naming conventions with a rename map.

## What to build

### Rules & Glossary

Add to GLOSSARY.md:
- **Script**: executable file in `scripts/bin/` with a shebang. Used when called from non-ZSH contexts (NeoVim, Kitty, Ubuntu keybindings, cron) or when a non-ZSH interpreter is needed.
- **Autoloaded Function**: ZSH function in `tools/term/zsh/config/functions/autoload/`. Default choice — faster, ZSH-native.
- **Binary Wrapper (-bin)**: thin script that wraps an autoloaded function so it can be called from external contexts. Named `<function-name>-bin`.

Add to CLAUDE.md:
- Default: autoloaded function
- Script required when: called by NeoVim, Kitty, cron/systemd, Ubuntu keybindings, non-ZSH interpreter
- `# Script because:` justification comment on line 3 of ZSH scripts
- Doc comment: line 1 for autoloaded functions, line 2 for scripts
- Naming: `domain-action` pattern (e.g. `git-commit-cancel`, `png-alpha`)

### Naming Conventions & Rename Map

HITL session to resolve:
- Image domain: gifmin→gif-min, jpgmin→jpg-min, pngalpha→png-alpha, etc.
- System domain: cpu-percent→sys-cpu-percent, ram-percent→sys-ram-percent
- Rename domain: file2dir, prefix-date, rename-fat32, capitalize-title, sequential-rename, filename-valid
- Media conversion: mp4min→mp4-min, naming consistency for bin2iso, dds2png, mp42avi, mp42mp3, vcd2mpg
- Text/Encoding: base64decode, base64encode, zsh2json, xml2json
- Individual renames: algolia-download→algolia-index-download, version-compare→version-is-newer, etc.
- Bash keeps: file-count, my-ip, ping-average, sort-by-length, unmark

Output: a rename map file in the plan directory consumed by subsequent domain issues.

## Acceptance criteria

- [ ] GLOSSARY.md has entries for Script, Autoloaded Function, Binary Wrapper
- [ ] CLAUDE.md has rules for when to use script vs autoloaded function
- [ ] Rename map written to plan directory
- [ ] All naming overlaps resolved
- [ ] User confirmed rename map
