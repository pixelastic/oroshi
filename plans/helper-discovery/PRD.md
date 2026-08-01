## Problem Statement

Agents writing zsh code are instructed to prefer existing helpers over porcelain commands, but have no way to discover which helpers exist among the ~900 autoload functions and scripts. The only aids are a 7-entry examples table and a noisy `!tree` dump that agents can't efficiently parse.

## Solution

Two new zsh autoload functions (`helper-list-raw` and `helper-list`) that scan both helper directories and return matching helpers with their descriptions. Agents call `helper-list-raw <keywords>` to discover helpers programmatically; humans call `helper-list <keywords>` for a colorized view.

## User Stories

1. As an agent writing zsh code, I want to search helpers by keyword, so that I use existing helpers instead of reinventing porcelain wrappers
2. As an agent, I want to see the filepath of each helper, so that I can read its source to understand arguments and behavior
3. As an agent, I want fuzzy matching on helper names, so that I find helpers even when unsure of exact naming
4. As a human, I want a colorized helper listing, so that I can quickly scan what's available in a domain
5. As a human, I want keyword order to not matter, so that `helper-list branch git` works the same as `helper-list git branch`
6. As an agent, I want `calling-commands.md` to reference `helper-list-raw`, so that every zsh-writer session knows the tool exists
7. As a developer, I want stray non-helper files (`.md`, `.gif`, `.conf`) removed from helper directories, so that scans return only real helpers

## Implementation Decisions

- Two functions following the established `*-list-raw` / `*-list` pattern (16 existing pairs in codebase)
- Both live in `autoload/misc/`
- `helper-list-raw` does all logic: scans `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/` and `$OROSHI_ROOT/scripts/bin/`, extracts descriptions, filters via `fzf --filter`
- Description extraction: line 1 if no shebang, line 2 if shebang present, strip leading `# `
- Internal `_extract_description` function (not public)
- Output: `name▮description▮filepath` (3 fields, `▮` separator)
- Filepath is absolute
- At least 1 argument required
- `helper-list` is a pure wrapper: calls `helper-list-raw`, colorizes name (yellow/executable color) and description (`$COLORS[comment]`), aligns columns
- Live scan every call, no caching
- `find -type f`, exclude paths containing `__`
- Fuzzy matching and ranking handled entirely by `fzf --filter`

## Testing Decisions

- Tests only for `helper-list-raw` (bats)
- `helper-list` is pure presentation, no tests
- Test scenarios: argument validation, output format (3 `▮`-separated fields), known keyword returns results, unknown keyword returns nothing, filepath is absolute
- Prior art: existing `*-list-raw` tests in the codebase (e.g. `git-branch-list-raw`, `yarn-script-list-raw`)

## Out of Scope

- Caching or index generation
- Description search (search is on names only; descriptions appear in output)
- Interactive fzf mode (this is `--filter` only, non-interactive)
- Changing helper naming conventions

## Further Notes

- The cleanup of stray files (`.md`, `.gif`, `.jpg`, `.conf`, `.docx`) in helper directories is a prerequisite to keep scan results clean
- `fzf --filter` is a new usage pattern in this codebase (existing fzf usage is all interactive)
