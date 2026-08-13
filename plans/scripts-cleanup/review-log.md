## Issue 02 — Rename root-level scripts
### Indentation stripped in spotify-is-running
```zsh
spotify-dbus current |
\grep --silent "Error: Spotify is not running" &&
exit 1
```
**Problem:** Pipe chain indentation was removed when renaming `sp` to `spotify-dbus`
**Reason skipped:** No documented indentation rule; the linter (`zsh-lint`) did not flag it, and the file was reformatted by the linter itself

### No reference updates for header/post
**Problem:** No grep evidence of repo-wide reference updates for old `header` and `post` command names
**Reason skipped:** Pre-implementation exploration confirmed no references to these commands exist outside plans/

### No compdef entries touched
**Problem:** Checklist item 3 requires checking compdef entries
**Reason skipped:** Pre-implementation exploration confirmed no compdef entries exist for any of the 6 renamed commands

### chmod-default placed in misc/ vs "find domain"
**Problem:** Spec says "find domain" but file was placed in `misc/`
**Reason skipped:** "find domain" means "find an appropriate domain", not the `find/` directory; `misc/` contains similar file utilities like `better-rm`

## Issue 03 — Migrate root-level scripts to autoloaded functions
### colors uppercase constants not local
```zsh
KITTY_CONF="$OROSHI_ROOT/tools/term/kitty/config/colors.conf"
PALETTE_REGEX="^(red|green|..."
RESET="\e[0m"
```
**Problem:** Uppercase constants not declared `local`
**Reason skipped:** Pre-existing pattern, unchanged by this diff. Script-level constants intentionally uppercase per convention.

### better-ydotool hardcoded path
```zsh
YDOTOOL_SOCKET=/home/tim/local/tmp/oroshi/ydotool/socket \
  ydotool $@
```
**Problem:** Hardcoded absolute path
**Reason skipped:** Pre-existing, unchanged from original. Out of scope for migration.

### extract return without exit code
```zsh
if [[ $# == 0 ]]; then
  echo "Select at least one file to extract"
  return
fi
```
**Problem:** `return` without explicit exit code
**Reason skipped:** Pre-existing behavior, unchanged. Borderline — could be `return 1` but not a clear rule violation.

### gif2png migration asymmetry
**Problem:** `scripts/bin/gif2png` deleted but no new autoloaded version created in this diff
**Reason skipped:** gif2png already existed as a proper autoloaded function in `img/gif/gif2png` from a prior change. Bin copy was a stale duplicate.

## Issue 05 — Skills cleanup
### Symlinks in ~/.claude/skills/ not in diff
**Problem:** Spec says "replace with symlinks in `~/.claude/skills/`" but no diff creates those symlinks
**Reason skipped:** Symlinks in `$HOME` are outside the git repo and can't be tracked in version control. They were created at runtime during implementation and already exist on the machine.

## Issue 06 — Create text/ domain
### translate/txt2slack naming convention
```zsh
translate
txt2slack
```
**Problem:** Names don't follow `{domain}-{action}` convention (should be `text-translate`, `text-to-slack`)
**Reason skipped:** Spec explicitly says "Keep name, move to text/ domain" for both

### if/else in txt2slack fallback
```zsh
if [[ $result == "" ]]; then
  echo "$inputText"
  return 0
fi
echo "$result"
```
**Problem:** Could use return-early pattern
**Reason skipped:** Single-level if with fallback output on both branches; converting wouldn't simplify

### Unquoted $result in [[ ]]
```zsh
if [[ $result == "" ]]; then
```
**Problem:** Convention is to quote variables
**Reason skipped:** Inside `[[ ]]` quoting is optional in zsh (no word splitting); not a rule violation

## Issue 07 — Migrate ubuntu/ to system/
### workspace-switch unquoted $workspaceIndex
```zsh
wmctrl -s $workspaceIndex
```
**Problem:** Unquoted variable expansion
**Reason skipped:** Numeric variable from arithmetic, no word-splitting risk

### workspace-switch uses bc for arithmetic
```zsh
local workspaceIndex=$(echo "$1 - 1" | bc)
```
**Problem:** Uses external `bc` instead of native `$((...))` arithmetic
**Reason skipped:** Pre-existing code, preserved from original script; no explicit rule banning `bc`

### clipboard-write if/then/fi instead of one-liner
```zsh
if [[ "$input" == "" ]]; then
  input="$(cat)"
fi
```
**Problem:** Could be a one-liner guard
**Reason skipped:** Side-effectful stdin read; multi-line form is clearer for this case

### Spec "Callers to update" not touched
**Problem:** Spec lists callers needing updates but none were changed
**Reason skipped:** All callers reference functions by name, not path; autoload resolves identically to PATH — no code changes needed

## Issue 08 — Migrate css/go/html linters/fixers
### Nested if/else in css-lint and html-lint
```zsh
if [[ $projectRoot != "" ]] && [[ -f $projectStylelintBin ]]; then
  stylelintBin=$projectStylelintBin
else
  stylelintBin=$globalStylelintBin
fi
```
**Problem:** Nested if/else instead of return-early pattern
**Reason skipped:** State-building branches selecting between two values, not early-termination candidates; flattening would not simplify

### _languages/css/ path inconsistency
**Problem:** `css-lint` placed in `_languages/css/` while `go/` and `html/` are top-level domains
**Reason skipped:** Spec explicitly prescribes `_languages/css/` domain, and `css-fix` already lives there

### function keyword on inner function in gotmpl-fix
```zsh
function applyFormatters() {
```
**Problem:** Uses `function` keyword syntax for inner function
**Reason skipped:** Linter reformatted it to this style; no explicit rule in zsh-writer forbids it

## Issue 09 — Migrate python/toml
### Commented-out code block indentation in python-fix
```zsh
# ruff check \
  #   --stdin-filename "$overridePath" \
  #   --fix \
  #   <"$workfilePath" \
  #   >"$tmpPath" 2>/dev/null
```
**Problem:** Comment continuation lines have inconsistent `#` prefix indentation
**Reason skipped:** Linter auto-reformats this block; manual fixes get overwritten

### fly-lint grep -v indentation
```zsh
grep -v '^.\{1,3\}|')
```
**Problem:** Line not indented to match the pipeline above it
**Reason skipped:** Pre-existing from original script; no explicit indentation rule documented

## Issue 10 — Migrate misc/ and docker/
### echo $output unquoted in docker-image-list
```zsh
echo $output | column \
```
**Problem:** `$output` is unquoted
**Reason skipped:** Intentional — unquoted `echo` lets zsh expand `\n` sequences; quoting would break multiline output

### docker-image-pull $@ collapsed to string
```zsh
local images="$@"
```
**Problem:** All positional args collapsed into single string, then re-split with `${=images}`
**Reason skipped:** Pre-existing pattern from original script, unchanged by migration

### docker-image-pull unquoted $imageName
```zsh
docker image pull $imageName
```
**Problem:** Unquoted variable expansion
**Reason skipped:** Docker image names cannot contain spaces; safe in practice

### better-rm nested if/else in loop
```zsh
if [[ $isMountedFile == 1 ]]; then
  mountedFiles+=("$filepath")
else
  regularFiles+=("$filepath")
fi
```
**Problem:** Nested if/else instead of return-early
**Reason skipped:** Single-level if/else inside a loop sorting items into two arrays; break already short-circuits inner loop

### better-rm domain TBD in spec
**Problem:** Spec marks `better-rm` domain as TBD but implementation placed it in `misc/`
**Reason skipped:** All other `better-*` functions live in `misc/` — consistent placement

### docker-image-list --key indentation
```zsh
    --key 1,1d \
  --key 2,2r
```
**Problem:** Misaligned continuation line for sort args
**Reason skipped:** Linter (beautysh) reformats to this style; manual fix gets overwritten

## Issue 11 — Migrate js/ and json/
### json-head unquoted $inputFile
```zsh
jq \
  ".[:${headLimit}]" \
  $inputFile
```
**Problem:** `$inputFile` is unquoted in jq call
**Reason skipped:** Pre-existing code, not introduced by this diff

### json-random no guard clause for missing args
```zsh
if [[ -p /dev/stdin ]]; then
  output="$(jq --argjson random "$RANDOM" '.[$random % length]')"
else
  local inputFile="$1"
  output="$(jq --argjson random "$RANDOM" '.[$random % length]' "$inputFile")"
fi
```
**Problem:** No guard for missing arguments when no stdin
**Reason skipped:** Judgment call — jq errors naturally with missing input; pre-existing behavior unchanged by migration

## Issue 13 — Migrate audio/mic2txt
### wav2txt-openai uses function name() with parens
```zsh
function isFileTooBig {
function transcribeFile {
function splitAndTranscribe {
```
**Problem:** Functions use `function name()` syntax with parentheses
**Reason skipped:** Cosmetic, no explicit rule forbids either form in zsh-writer standards

### mic2txt-raw nested if blocks in stopRecording
```zsh
if [[ -f $autocorrectFile ]]; then
if [[ $language != "fr" ]]; then
if mic2txt-slack-mode-is-enabled; then
if mic2txt-autosubmit-mode-is-enabled; then
```
**Problem:** Multiple if blocks inside stopRecording function
**Reason skipped:** Sequential transformations on $transcription, not nested conditionals; return-early doesn't apply to mid-function data mutations

## Issue 14 — Migrate audio/ general scripts
### audio-split variable names output1/output2/basename
```zsh
local basename="${input:r}"
local output1="${basename}-part1.${extension}"
local output2="${basename}-part2.${extension}"
```
**Problem:** Variable names could be more descriptive; `basename` shadows the command
**Reason skipped:** Full words, not abbreviations; `output1`/`output2` clear for a two-part split

### sound-mode-toggle if/else block
```zsh
if [[ -f $storeFile ]]; then
  rm $storeFile
else
  touch $storeFile
fi
```
**Problem:** Uses if/else instead of return-early
**Reason skipped:** Legitimate binary toggle (create vs remove), not a guard clause

### Behavioral tests use real filesystem
```bash
STORE_DIR="$HOME/local/tmp/oroshi/sound-mode"
```
**Problem:** Tests read/write real `$OROSHI_TMP_FOLDER` instead of isolated `bats_tmp_dir`
**Reason skipped:** Functions hardcode `$OROSHI_TMP_FOLDER` which is set by zshenv; tests save/restore state in setup/teardown

## Issue 15 — Migrate fzf/
### Existing autoloaded functions repeat functions_source on each source line
```zsh
source "${functions_source[$0]:A:h}/__lib/init.zsh"
source "${functions_source[$0]:A:h}/__lib/fzf-options-prompt-directory.zsh"
source "${functions_source[$0]:A:h}/__lib/fzf-fs-preview.zsh"
source "${functions_source[$0]:A:h}/__lib/fzf-colorize-git-status-path.zsh"
```
**Problem:** 5 existing autoloaded functions repeat `${functions_source[$0]:A:h}` per line instead of extracting to `local __lib=` variable like newly migrated functions
**Reason skipped:** Pre-existing inconsistency, not introduced by this diff; out of scope for this migration

## Issue 19 — Migrate zsh-lint + zsh-fix
### snake_case variables in zsh-lint
```zsh
local invalid_json='[]'
local valid_json='[]'
```
**Problem:** Uses `snake_case` instead of project's `camelCase` convention
**Reason skipped:** Pre-existing naming from original script, not introduced by migration

### NeoVim filetypes/zsh.lua not updated
**Problem:** Spec lists `filetypes/zsh.lua → zsh-fix, zsh-lint` under "NeoVim configs to update"
**Reason skipped:** Config references commands by name, not path; autoloaded functions resolve identically — no code change needed

## Issue 21 — Migrate google/
### for loops in wrapText/writeOutput
```js
for (const word of words) {
```
**Problem:** js-writer checklist forbids `for` loops, prefers `_.each`/`_.map`/`_.reduce`
**Reason skipped:** Pre-existing code moved verbatim; `wrapText` is an accumulator where `_.reduce` would be less readable

### google-login.js flat script structure
```js
const server = http.createServer(async (request, response) => {
```
**Problem:** No `__` pattern, no named export, no JSDoc — violates js-writer module conventions
**Reason skipped:** Imperative OAuth server script, restructuring out of scope for a move operation

### node:fs/promises instead of firost
```js
import { mkdir, writeFile } from 'node:fs/promises';
```
**Problem:** js-writer references firost for file I/O
**Reason skipped:** Pre-existing code, `node:fs/promises` not explicitly prohibited

### review-blog-start not updated
**Problem:** Spec lists `review-blog-start` under "Update callers"
**Reason skipped:** File doesn't reference gdocs/gdoc names — only calls `md2gdocs` which is unrelated; spec entry is stale

## Issue 23 — Migrate git/
### if/else in git-pullrequest-open
```zsh
if [[ $prNumber != "" ]]; then
  openedUrl="${openedUrl}/pull/${prNumber}"
else
  openedUrl="${openedUrl}/pulls"
fi
```
**Problem:** Could be a one-liner state-machine pattern per conditions reference.
**Reason skipped:** Shallow if/else (no nesting), reads clearly, two branches set different suffixes.

### Guard clauses with messages in git-directory-create and git-remote-create
```zsh
if [[ $repoName == "" ]]; then
  echo "You must pass the name of the new repo"
  return 1
fi
```
**Problem:** Guard clauses use if/fi instead of one-liner return-early.
**Reason skipped:** Guards print user-facing error messages before returning, requiring multi-line blocks. They are at function top and return early — spirit of the rule is followed.

### Bottom if block in git-directory-create and git-directory-create-all
```zsh
if [[ $isLocal == "0" ]]; then
  # multi-line remote setup
fi
```
**Problem:** Could use early return for local-only case to avoid wrapping if.
**Reason skipped:** Single-level if, not nested. Early-return refactor is arguable but current form is clear.

### if block for URL derivation in git-remote-create
```zsh
if [[ "$remoteUrl" == "" ]]; then
  remoteUrl="$(git-remote-url)"
  remoteUrl="${remoteUrl/...}"
fi
```
**Problem:** if block could be flattened.
**Reason skipped:** Single-level, no else, conditional setup reads cleanly as-is.

## Issue 24 — Migrate small domains
### `function` keyword in kindle-sync inner helper
```zsh
function getAllMobi() {
```
**Problem:** Uses `function` keyword for inner helper function.
**Reason skipped:** No explicit rule in zsh-writer against `function` keyword for inner helpers.

### pdf-extract-images.js lacks JSDoc and named exports
```js
import { extractImages } from 'pietro';
await pMap(args, async (arg) => {
```
**Problem:** No JSDoc, no named exports, not testable via vitest.
**Reason skipped:** Straight port of existing bin script; file is a CLI entry point, not a reusable module.

### `_sanitize_section` and `_format_ini` underscore prefix
```zsh
function _sanitize_section() {
function _format_ini() {
```
**Problem:** Inner functions use underscore prefix naming convention.
**Reason skipped:** No explicit naming rule for inner helper functions in zsh-writer.

### video-stream-list jq arg indentation
```zsh
video-info $1 \
  | jq -r \
  '.streams[] | "\(.index)▮\(.codec_type)▮\(.tags.title)▮\(.tags.language)"' \
  | table
```
**Problem:** jq filter string at same indent level as pipeline operators.
**Reason skipped:** beautysh linter enforces this indentation; manual fix gets reverted.
