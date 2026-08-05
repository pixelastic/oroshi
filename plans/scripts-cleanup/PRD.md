## Problem Statement

The `scripts/bin/` directory contains 376 scripts accumulated over years. There are no explicit rules for when something should be a script vs an autoloaded ZSH function. ~40% of scripts are dead code (broken dependencies, superseded by ZSH equivalents, unused tools like cmus). ~29% lack doc comments. There is no lint enforcement for documentation or script justification. The result: cognitive overhead when navigating the codebase, confusion about where new tools belong, and no guardrails to prevent further drift.

## Solution

A multi-pass cleanup of `scripts/bin/`:
1. Delete dead code (~70 scripts + `__pdf/` directory)
2. Define explicit rules for script vs autoloaded function in GLOSSARY.md and CLAUDE.md
3. Establish naming conventions and domain organization for surviving scripts
4. Rewrite Ruby/Bash scripts to ZSH
5. Migrate eligible ZSH scripts to autoloaded functions
6. Add doc comments to everything that remains
7. Add lint rules to enforce documentation and script justification going forward

## User Stories

1. As a developer, I want dead scripts removed, so that I don't waste time reading or maintaining unused code
2. As a developer, I want clear rules for script vs autoloaded function, so that I know where to put new tools
3. As a developer, I want every script to explain why it's a script (not an autoloaded function), so that future decisions are informed
4. As a developer, I want all scripts to have doc comments, so that I can understand what a script does without reading its implementation
5. As a developer, I want lint rules that enforce doc comments and script justification, so that the codebase doesn't drift back to its current state
6. As a developer, I want consistent naming conventions (domain-action pattern), so that scripts are discoverable by name
7. As a developer, I want Ruby/Bash scripts rewritten in ZSH, so that the codebase uses a single shell language
8. As a developer, I want eligible scripts migrated to autoloaded functions, so that shell startup is faster and ZSH-native features are used
9. As a developer, I want aliases updated when scripts are renamed or migrated, so that muscle memory isn't broken
10. As a developer, I want the `-bin` wrapper pattern formalized, so that autoloaded functions that need external callers have a clean convention

## Implementation Decisions

### Module 1 — Dead Code Deletion
- Bulk `git rm` of 70+ scripts confirmed dead during the audit
- Split into sub-issues by language (Ruby, Bash, sh/node, ZSH) for clean commits
- Also delete `__pdf/` directory (replaced by Pietro JS lib), `simplify`, `html2mkd`
- Clean up remark config alongside remark-fix/remark-lint deletion
- Clean up dead aliases (e.g. `trl` for trash-list, `rmdir` alias if better-rmdir is migrated)

### Module 2 — Rules & Glossary
- Add glossary entries: "Script", "Autoloaded Function", "Binary Wrapper (-bin)"
- Add CLAUDE.md rules: when to use script vs autoloaded function
- Script required when: called by NeoVim, Kitty, cron/systemd, Ubuntu keybindings, or needs non-ZSH interpreter
- Default: autoloaded function (preferred — faster, ZSH-native)
- `-bin` suffix pattern: thin script wrapper when an autoloaded function needs to be callable externally
- `# Script because:` justification comment on line 3 of ZSH scripts

### Module 3 — Naming & Domain Reorganization
- Design step: group all scripts flagged for rename, identify domain/subdomain patterns, resolve overlaps
- Image scripts: domain-action (gif-min, png-alpha, jpg-min)
- System scripts: sys- prefix (cpu-percent → sys-cpu-percent)
- File-renaming scripts: potential "rename" domain (file2dir, prefix-date, rename-fat32, capitalize-title, sequential-rename, filename-valid)
- Media conversion scripts: naming consistency (mp4-min, bin2iso, dds2png, mp42avi, mp42mp3, vcd2mpg)
- Encoding/text: base64decode, base64encode, zsh2json, xml2json
- Individual renames: algolia-download→algolia-index-download, version-compare→version-is-newer, etc.
- Produces a rename map consumed by Modules 4 and 5

### Module 4 — Ruby/Bash → ZSH Rewrites
- Rewrite 13 Ruby scripts and 6 Bash scripts to ZSH
- Use rename map from Module 3
- Each rewrite is small and independent
- Some rewrites may be complex (html2pdf — evaluate feasibility, delete if too complex)
- Follow ZSH conventions: `setopt local_options err_return`, no shebang for autoloaded functions, `set -e` for scripts

### Module 5 — Script → Autoloaded Function Migration
- Evaluate 91 ZSH scripts: stay as script or migrate to autoloaded function
- For each: check if any external caller exists (NeoVim, Kitty, keybindings, other non-ZSH contexts)
- Migration mechanics: remove shebang, move doc comment to line 1, add `setopt local_options err_return`, move to `tools/term/zsh/config/functions/autoload/<domain>/`
- Scripts that stay: add `# Script because:` justification
- Update aliases and references
- Apply renames from Module 3

### Module 6 — Documentation Pass
- Add missing `# Description` comments to all surviving scripts (line 2) and autoloaded functions (line 1)
- Applies to callable scripts/functions only — NOT `__lib/`, `__rules/`, fixtures
- 537 autoloaded functions also need auditing (separate sub-issue from scripts)

### Module 7 — Lint Rules
- `missingDocComment`: error if autoloaded function has no `#` on line 1, or script has no `#` on line 2
- `missingScriptJustification`: error if ZSH script in `scripts/bin/` lacks `# Script because:` on line 3
- Follow existing rule pattern in `zsh-lint/__rules/`
- Implement last, after all cleanup/migration/docs are done

## Testing Decisions

- Lint rules (Module 7) should have bats tests, following the pattern of existing rules in `zsh-lint/__rules/__tests/`
- Ruby/Bash → ZSH rewrites should have bats tests where the original had non-trivial logic
- Migration of scripts to autoloaded functions needs manual verification (run the function, check aliases work)
- Dead code deletion needs no tests — the absence of errors after deletion is the test

## Out of Scope

- Autoloaded function refactoring (only doc comments are in scope, not code changes)
- `scripts/etc/` cleanup (noted in memory as separate project)
- Rewriting `simplify`/`html2mkd` with modern tools (just deleting them)
- Pietro JS library for PDF tooling (separate project)
- The actual implementation of subtitle tooling via Subliminal

## Further Notes

- The full per-script audit decisions are in `/tmp/oroshi/claude/scripts/scripts-audit-decisions.md`
- History analysis used word-boundary matching on `~/.history` (54k lines) to determine "alive" scripts
- 197 scripts were confirmed alive (176 in history + 21 as dependencies)
- The audit was interactive — each script was reviewed with the user
