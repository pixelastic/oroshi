---
name: zsh-writer
description: Use when writing or modifying ZSH functions.
---

# ZSH Writer

## Overview

Write ZSH code that is consistent with my conventions.

## Core Workflow

### Step 1 — Place the file

**Goal:** Correct path and name.

**Exit criterion:** File exists at correct path with correct name.

- Autoloaded (preferred, called from zsh): `config/term/zsh/functions/autoload/{domain}/{subdomain?}/{name}`
- Standalone (called externally like from keybindings): `scripts/bin/{domain}/{subdomain?}/{name}`
- Name: `{domain}-{subdomain?}-{action}` — e.g. `git-branch-list`, `json-lint`
- `-raw` suffix → machine-readable `▮`-separated output, consumed by other scripts

### Step 2 — Write the code

**Goal:** Code follows all patterns.

**Exit criterion:** Checklist passes.

Write code that follows the following patterns:


| Pattern | Rule |
|---|---|
| [Headers](./references/header.md) | Top of the file: what the script does, how to call it and error protection |
| [Args Parsing](./references/args-parsing.md) | Use `zmodload zsh/zutil` + `zparseopts -E -D` to parse args |
| [Variables](./references/variables.md) | `local myVar="$(myCommand)"` on one line |
| [Modifiers](./references/modifiers.md) | Prefer zsh modifiers (`${filepath:t}`) over commands (`$(basename "$filepath")`) |
| [Splitting](./references/splitting.md) | Use `▮` as separator and `${(@ps/▮/)line}` to split |
| [Loops](./references/loops.md) | Use `for rawLine in ${(f)rawOutput}` instead of `while read` and `IFS` |
| [Conditions](./references/conditions.md) | `[[ simpleCondition ]] && state=value`. No nested if/else, return early, no `-z`/`-n` |
| [Calling Commands](./references/calling-commands.md) | Use existing helpers (`git-branch-current`), not raw calls. Use `--long-form`, not `-l`. |


```zsh
# Show changed files with syntax-aware coloring
# Usage:
# $ git-diff-colorize            # Unstaged changes
# $ git-diff-colorize --staged   # Staged only
# $ git-diff-colorize --ext ts   # Filter by extension
setopt local_options errexit

MAX_RESULTS=50

zmodload zsh/zutil
zparseopts -E -D \
  s=flagStaged \
  -staged=flagStaged \
  e:=flagExt \
  -ext:=flagExt

local isStaged=${#flagStaged}
local extFilter=${flagExt[2]}

local helperArgs=()
[[ $isStaged == 1 ]] && helperArgs+=(--staged)
[[ "$extFilter" != "" ]] && helperArgs+=(--ext "$extFilter")

local rawFiles="$(git-diff-list-raw "${helperArgs[@]}")"

# Nothing to display if working tree is clean
[[ "$rawFiles" == "" ]] && return 0

local output=""
for rawLine in ${(f)rawFiles}; do
  local fields=(${(@ps/▮/)rawLine})
  local name=$fields[1]
  local dir=$fields[2]
  local ext=$fields[3]

  local parentDir="${dir:t}"  # zsh modifier: last path component

  local color=$COLOR_DEFAULT
  [[ "$ext" == "ts" ]] && color=$COLOR_FILE_TS
  [[ "$ext" == "zsh" ]] && color=$COLOR_FILE_ZSH

  output+="$(colorize "$name" $color)▮$parentDir▮$ext\n"
done

table $output
```

### Step 3 — Lint the file

Run `zshlint <file>` on the file and fix any actionable violation.

### Step 4 — Run the tests

If a `.bats` test file exists for this script, run `bats <test-file>`. All tests must pass.

> `zshlint` and `bats` are both in PATH — call them directly, no full path needed.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "`local` exits 0, I need it on its own line | No, I want `local myVar="$(myCommand)"` even if `myCommand` could fail |
| "`while read` is fine for simple cases" | Never. `${(f)var}` always. |
| "It's only two levels of if/else, it's ok." | No it's not. Return early, always. |

## Checklist

- [ ] Quick documentation and usage at top of script
- [ ] `zparseopts` for all flag parsing
- [ ] Return early — no avoidable nesting
- [ ] Comments for each guard clause
- [ ] All function vars `local`; script constants UPPER_CASE without `local`
- [ ] No `while read` — only `${(f)var}` or `"${(@f)var}"`
- [ ] External commands use long-form args, one per line
- [ ] Use existing helpers over porcelain (e.g. `git-branch-list-raw` not `git branch`)
