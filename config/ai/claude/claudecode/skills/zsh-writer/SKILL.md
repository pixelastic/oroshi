---
name: zsh-writer
description: Use when writing or modifying ZSH functions in the .oroshi repository, especially when creating scripts with argument parsing, line-by-line iteration, or structured data output
---

# ZSH Writer

## Overview

Write ZSH functions following established patterns for the .oroshi dotfiles repository. These patterns emphasize ZSH-specific idioms over bash compatibility, explicit variable scoping, and consistent data formatting.

## Philosophy

Write ZSH code that is:
- **Minimal** - Only what's necessary
- **Readable** - Code should be self-documenting
- **Simple** - Straightforward logic, let `set -e` handle errors
- **Pragmatic** - Use what works

**When in doubt, leave it out.** This applies to comments, defensive checks, and abstractions.

## Core Coding Guidelines

**Related skill:** `code-writer` - Defines core guidelines for comments and output statements that apply across all programming languages. This `zsh-writer` skill extends those general principles with ZSH-specific patterns and conventions.

## When to Use

- Writing new ZSH functions in `config/term/zsh/functions/autoload/`
- Modifying existing ZSH scripts
- Creating utilities that parse arguments, iterate over data, or format output

**When NOT to use:**
- FZF-related functions (they have their own nomenclature)
- One-off shell commands (not functions)
- Bash scripts (different conventions)

## Code Style: Echo and Comments

### Echo Statements

**Default: ZERO echo statements.**

**Allowed ONLY for:**
1. **Display functions** (name ends in `-list`, `-colorize`, `-format`, `-display`) - echo IS the functionality
2. **Error messages** - Usage errors to stderr: `echo "Error: ..." >&2`

**FORBIDDEN:**
- Progress messages (`"Processing..."`, `"Starting..."`)
- Status/summary (`"Found X items"`, `"Total: ..."`)
- Empty lines (`echo ""`)
- Decorative headers in echo (`"Summary:"`, `"======"`)

```zsh
# ✅ Display function - echo IS the purpose
function git-branch-list() {
  echo "$branchName"
}

# ✅ Error message with usage
if [[ -z "$arg" ]]; then
  echo "Error: Argument required" >&2
  echo "Usage: func <arg>" >&2
  return 1
fi

# ❌ Analysis function - NO narration
function count-errors() {
  local count=$(rg --count "ERROR" "$file")
  # NO echo of results/progress/summary
  return 0
}
```

**If unsure whether to add echo: DON'T.**

### Comments

**Default: Function header ONLY.**

**Allowed:**
1. **Function header** - description + usage (always required)
2. **Section comments** - ONE comment for 3+ grouped operations
3. **Data meaning** - Explains what data represents (not what code does)

**FORBIDDEN:**
- Comments explaining what code does
- One comment per operation
- Loop comments (`# Process each X`)
- Validation comments (unless ONE for 3+ validations)
- Variable initialization comments
- **Decorative borders** (`# ====`, `# ----`, `# ~~~`)

```zsh
# ✅ Function header
# List all git branches
# Usage:
# $ git-branch-list
function git-branch-list() {

# ✅ ONE section comment for grouped validations
# Validate arguments and repository state
if [[ -z "$arg1" ]]; then return 1; fi
if [[ -z "$arg2" ]]; then return 1; fi
if [[ -z "$arg3" ]]; then return 1; fi

# ✅ Data meaning
# First line is the header
if [[ $lineNumber -eq 1 ]]; then

# ❌ FORBIDDEN - Explains what code does
# Check if file exists
if [[ ! -f "$file" ]]; then

# ❌ FORBIDDEN - Loop comment
# Process each log file
for logFile in ${(f)logFiles}; do
```

**When editing existing code: Never remove existing comments.**

**If unsure whether to add comment: DON'T.**
## File Organization

```
config/term/zsh/functions/autoload/
├── domain/                    # Simple domains (no subdomain needed)
│   └── domain-action
└── domain/                    # Complex domains with subdomains
    └── subdomain/
        └── domain-subdomain-action
```

**Naming convention:** `{domain}-{subdomain?}-{action}`

Examples:
- `git-branch-list` (domain: git, subdomain: branch, action: list)
- `docker-image-colorize` (domain: docker, subdomain: image, action: colorize)
- `trim` (simple utility, no domain prefix needed)

**Directory structure:**
- No subdomain needed → files directly in `domain/`
- Subdomain needed → create `domain/subdomain/` folder

## Script Structure

**Always include `set -e` after the shebang:**

```zsh
#!/usr/bin/env zsh
set -e

# Script content here
```

This ensures the script exits immediately on any error, eliminating the need for defensive checks throughout.

## Variable Declaration

**Always use `local` for all variables in functions:**

```zsh
# ✅ CORRECT
function my-function() {
  local inputFile="$1"
  local outputDir="$2"
  local result=""

  # ... code ...
}

# ❌ WRONG
function my-function() {
  inputFile="$1"        # Missing local
  result=""             # Missing local
}
```

**Naming conventions:**
- `camelCase` for local variables in functions
- `UPPER_CASE` for script-level constants (without `local`)
- `UPPER_CASE` for globals (e.g., `$COLOR_ALIAS_*`)

**IMPORTANT:** Configuration constants at script level must NOT use `local` - they are script constants, not function-local variables.

**Initialize with empty string when setting later:**

```zsh
local description=""

if [[ condition ]]; then
  description="value1"
else
  description="value2"
fi
```

## Variables vs. Literals

**Use variables for:**
- Empirical values that might need tuning (thresholds, timeouts, retry counts)
- Values used multiple times

**Use literals for everything else.**

**Configuration constants in scripts:**

For tunable values (thresholds, timeouts, retry counts), define as UPPER_CASE constants at the top of the script.

**CRITICAL: Do NOT use `local` for script-level constants.**

```zsh
#!/usr/bin/env zsh
# Triggered whenever Claude finishes answering

# ✅ CORRECT - Script constant in UPPER_CASE, no local
THRESHOLD=5
MAX_RETRIES=3

# ... rest of script ...
if ((durationSeconds < THRESHOLD)); then
  audio-play-oroshi "claude-stop-fast.mp3"
  exit 0
fi

# ❌ WRONG - Don't use local for script constants
local threshold=5  # This makes it function-local, not a script constant
local THRESHOLD=5  # Still wrong - local means function scope
```

**In functions, use `local` with camelCase:**

```zsh
function my-function() {
  local threshold=5  # Function-local variable
  local result=""
  # ...
}
```

**Literals for fixed values used once:**

```zsh
# ✅ Literal - fixed value used once
audio-play-oroshi "claude-stop-fast.mp3"
```

## Argument Parsing

**Use `zparseopts` for all argument parsing:**

```zsh
function docker-image-colorize() {
  zparseopts -E -D \
    -with-icon=flagWithIcon \
    -remote=flagRemote

  local isWithIcon=${#flagWithIcon}
  local isRemote=${#flagRemote}

  local imageName="$1"
  # ... rest of function
}
```

**Patterns:**

| Type | Declaration | Usage | Example |
|------|-------------|-------|---------|
| Boolean flag | `-flag=flagName` | `${#flagName}` gives 0 or 1 | `--force` |
| Long flag | `--long-flag=flagName` | `${#flagName}` | `--with-icon` |
| Short arg | `s:=flagName` | `${flagName[2]}` | `-s value` |
| Long arg | `--separator:=flagName` | `${flagName[2]}` | `--separator ▮` |

**Complete example with arguments:**

```zsh
zparseopts -E -D \
  f=flagForce \
  -force=flagForce \
  s:=flagSeparator \
  -separator:=flagSeparator

local isForce=${#flagForce}
local separator=${flagSeparator[2]}
```

**After `zparseopts -E -D`, positional arguments remain in `$1`, `$2`, etc.**

```zsh
local skillName="$1"
local targetDir="$2"
```

## Command-Line Argument Formatting

**Always prefer long-form arguments for readability:**

```zsh
# ✅ CORRECT - long-form arguments
fd --type file --glob "*.md" /path

# ❌ WRONG - short-form arguments
fd -t f -g "*.md" /path
```

**Multi-line formatting for commands with multiple arguments:**

```zsh
# ✅ CORRECT - each argument on its own line
yt-dlp \
  --cookies-from-browser firefox \
  --format 'bestvideo[height<=720]' \
  --output "%(title)s.%(ext)s" \
  "$videoId"

# ❌ WRONG - all on one line
yt-dlp --cookies-from-browser firefox --format 'bestvideo[height<=720]' --output "%(title)s.%(ext)s" "$videoId"
```

**Exception - command substitutions can remain one-line:**

```zsh
# ✅ ACCEPTABLE - in substitution, even with multiple args
local sessionFile=$(fd --type file --max-results 1 "*.jsonl" ~/.claude)

# ✅ ALSO ACCEPTABLE - split if very long
local sessionFile=$(fd \
  --type file \
  --max-results 1 \
  "*.jsonl" \
  ~/.claude/projects)
```

**Conditional arguments - use arrays:**

```zsh
# ✅ CORRECT - build array conditionally
local ytdlpArgs=(
  --cookies-from-browser firefox
  --format 'bestvideo[height<=720]'
  --output "%(title)s.%(ext)s"
)

if [[ $isVerbose -eq 1 ]]; then
  ytdlpArgs+=(--verbose)
fi

yt-dlp "${ytdlpArgs[@]}" "$videoId"

# ❌ WRONG - inline conditionals
yt-dlp --cookies-from-browser firefox $([ $isVerbose -eq 1 ] && echo "--verbose") "$videoId"
```

**Short-form exceptions (ONLY in command substitutions):**

These common idioms can use short forms when inside `$(...)`:

```zsh
# ✅ ACCEPTABLE - common idioms in substitutions
local firstLine=$(head -1 file.txt)
local lastLine=$(tail -1 file.txt)
local chars=$(cut -c 1-10 file.txt)
local raw=$(jq -r '.field' file.json)

# ⚠️ PREFER LONG FORM outside substitutions
head --lines=1 file.txt
tail --lines=1 file.txt
cut --characters=1-10 file.txt
jq --raw-output '.field' file.json
```

**Accepted short-form idioms (in substitutions only):**
- `head -N` / `tail -N` (any number)
- `cut -c`
- `jq -r`

**Rules summary:**
1. Default: always use long-form arguments (`--verbose` not `-v`)
2. Multiple arguments: one per line (unless in substitution)
3. Argument value: on same line as the argument
4. Conditional args: build array, add conditionally
5. Command substitutions: can be one-line
6. Short-form idioms: only in substitutions, only from accepted list

## Line-by-Line Iteration

**Always use `for item in ${(f)variable}` — NEVER `while read`:**

```zsh
# ✅ CORRECT - ZSH pattern
local rawOutput=$(some-command)
for rawLine in ${(f)rawOutput}; do
  # Process each line
done

# ❌ WRONG - bash pattern
echo "$rawOutput" | while IFS= read -r line; do
  # Don't use this
done
```

**Why:** `while read` creates a subshell and doesn't preserve variable assignments. The `${(f)}` flag is a ZSH builtin that's more efficient.

## String Splitting and Structured Data

**Use `▮` (vertical bar) as the universal separator:**

```zsh
# Creating structured output
echo "${uuid}▮${title}▮${count}"

# Splitting on ▮
local splitLine=(${(@ps/▮/)rawLine})
local field1=${splitLine[1]}
local field2=${splitLine[2]}
local field3=${splitLine[3]}
```

**The `(@ps/▮/)` flags:**
- `@` - preserve empty elements
- `p` - use parameter expansion
- `s/▮/` - split on ▮ character

**Alternative for simple splits (no empty elements):**

```zsh
local splitLine=(${(@s/▮/)rawLine})
```

## Function Naming Patterns

**`-raw` suffix for machine-readable output:**

Functions ending in `-raw` output structured data with `▮` separators for use by other scripts:

```zsh
# Machine-readable (required if human-readable version exists)
function git-branch-list-raw() {
  # Output: branchName▮commitHash▮remoteName▮...
}

# Human-readable (optional, uses -raw internally)
function git-branch-list() {
  local rawBranches="$(git-branch-list-raw)"
  for rawBranch in ${(f)rawBranches}; do
    local splitLine=(${(@ps/▮/)rawBranch})
    # Colorize and format for display
  done
}
```

**Not all `-raw` functions need a human-readable version**, but if you create a human-readable version, it should consume the `-raw` output.

## Reading from stdin

**Pattern for utilities that accept both arguments and piped input:**

```zsh
function trim() {
  local input="$1"
  # Read from pipe if available
  [[ -p /dev/stdin ]] && input="$(/usr/bin/cat -)"

  # Process input
  echo -n "$output"
}
```

**Use `/usr/bin/cat` not `\cat`** - explicit path is clearer than escaping aliases.

## Control Flow

**Return early to avoid nesting:**

```zsh
# ✅ CORRECT - return early
function skill-description() {
  local skillName="$1"
  local skillFile="$HOME/.agents/skills/${skillName}/SKILL.md"

  # Check and exit early
  if [[ ! -f "$skillFile" ]]; then
    return
  fi

  # Main logic not nested
  local description=$(extract-from "$skillFile")
  echo "$description"
}

# ❌ WRONG - nested logic
function skill-description() {
  local skillFile="$HOME/.agents/skills/${1}/SKILL.md"

  if [[ -f "$skillFile" ]]; then
    # Everything indented one level
    local description=$(extract-from "$skillFile")
    echo "$description"
  fi
}
```

**For functions that output values:**
- Just `return` (no output, no error message)
- Don't write to stderr

**For predicates/checks (like `-exists` functions):**
- Return exit codes: `return 0` for success, `return 1` for failure

## Error Handling

**Rely on `set -e` to stop on errors. Validate arguments early, then trust the data.**

```zsh
#!/usr/bin/env zsh
set -e

# Validate required arguments/state at the top
if [[ -n "${CUSTOM_OVERRIDE}" ]]; then
  handle-override
  exit 0
fi

# Rest of script assumes valid state - no defensive checks
local result=$(process-data)
```

**When to add validation:**
- User-facing errors with helpful messages at script start
- Critical preconditions before processing

**When to skip checks:**
- Mid-script validations (let `set -e` handle failures)
- Internal calculations (failures will exit via `set -e`)
- Edge cases that don't require user feedback

## Function Header Comments

**Include usage examples in comments:**

```zsh
# Extract the description from a skill's SKILL.md file
# Usage:
# $ skill-description blog-writing-guide
function skill-description() {
  # ...
}
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `while read` loops | Use `for item in ${(f)variable}` |
| No `local` declarations | Always prefix with `local` |
| `\|` or `:` as separator | Use `▮` character |
| Manual arg parsing with `while/case` | Use `zparseopts` |
| `container_name` (snake_case) | Use `containerName` (camelCase) |
| String boolean checks `[[ "$flag" == true ]]` | Use `${#flagName}` for 0 or 1 |
| External tools (`sed`, `awk`, `cut`) | Prefer ZSH parameter expansion when possible |
| Short-form args (`-t`, `-v`) | Use long-form (`--type`, `--verbose`) |
| All args on one line | One argument per line for multi-arg commands |
| `fd -t f -g pattern` | `fd --type file --glob pattern` (or multi-line) |
| Decorative borders (`# ====`) | Remove - no visual separators in comments |
| Variables for fixed values used once | Use literals - variables only for empirical/tuning values |
| `local threshold=5` at script level | Use `THRESHOLD=5` (UPPER_CASE, no local) for script constants |
| Environment variable defaults (`${VAR:-default}`) | Don't over-engineer - use simple variables |
| Multiple defensive checks mid-script | Validate early, then trust `set -e` |
| Verbose function headers (>3 lines) | Keep concise - describe what triggers the script |

## Quick Reference

```zsh
# Script-level constants (NO local!)
THRESHOLD=5
MAX_RETRIES=3

# Function variables (WITH local)
local varName="value"
local emptyVar=""

# Parse arguments
zparseopts -E -D \
  -flag=flagName \
  -option:=flagOption

local isFlag=${#flagName}
local optionValue=${flagOption[2]}
local positional="$1"

# Iterate lines
for line in ${(f)output}; do
  echo "$line"
done

# Split on ▮
local parts=(${(@ps/▮/)line})
local first=${parts[1]}

# Check stdin
[[ -p /dev/stdin ]] && input="$(/usr/bin/cat -)"

# Return early
if [[ ! -f "$file" ]]; then
  return
fi
```

## Real-World Examples

**Reference example** showing minimal, pragmatic style:

```zsh
#!/usr/bin/env zsh
# Triggered whenever Claude finishes answering

# If a custom sound is explicitly set, it takes precedence
if [[ -n "${OROSHI_CLAUDECODE_STOP_SOUND}" ]]; then
  audio-play-oroshi "${OROSHI_CLAUDECODE_STOP_SOUND}"
  exit 0
fi

THRESHOLD=5

# Read JSON input from stdin
local stdinData=$(cat)
local transcriptPath=$(echo "$stdinData" | jq -r '.transcript_path // empty')

# Calculate duration
local nowEpoch=$(date +%s)
local lastUserTime=$(/usr/bin/grep '"type":"user"' "$transcriptPath" |
  tail -1 |
  jq -r '.timestamp // empty' 2>/dev/null)
local userEpoch=$(date -d "$lastUserTime" +%s 2>/dev/null)
local durationSeconds=$((nowEpoch - userEpoch))

# Play different sound if fast or not
if ((durationSeconds < THRESHOLD)); then
  audio-play-oroshi "claude-stop-fast.mp3"
  exit 0
fi

audio-play-oroshi "claude-stop.mp3"
```

**Key patterns demonstrated:**
- Minimal header comment (one line)
- Section comments without decorative borders (optional)
- Configuration constant in UPPER_CASE at top (THRESHOLD), literals for fixed values (sound files)
- No defensive checks - lets calculations fail naturally
- Direct execution - no intermediate variables

**Additional examples in codebase:**
- `config/term/zsh/functions/autoload/claude/skill-description` - Simple function with early return
- `config/term/zsh/functions/autoload/docker/image/docker-image-colorize` - zparseopts usage
- `config/term/zsh/functions/autoload/git/branch/git-branch-list` - Complex example with -raw pattern

For more ZSH patterns, see `cheats/zsh/` directory:
- `parse-args.zsh` - zparseopts examples
- `line-by-line.zsh` - Iteration patterns
- `split.zsh` - String splitting
