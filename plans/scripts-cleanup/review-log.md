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
