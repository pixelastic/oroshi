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
