## TLDR

Rewrite `complete-jumps` to merge marks and projects, with projects winning on collision.

## What to build

Rewrite `tools/term/zsh/config/functions/autoload/completion/complete-jumps`:
1. Call `mark-list-raw` to get marks (`name▮path` lines)
2. Call `projects-load-definitions` to get PROJECTS
3. Iterate PROJECTS keys matching `*:path`, add entries not already in marks
4. For each entry, format as `name:description` (zsh completion format)
   - Projects: use `PROJECTS[name:icon]` + name as description when icon exists, else simplified path
   - Marks: use resolved path as description, but use project icon if one matches

Projects win on collision: if a name appears in both marks and projects, use the project entry.

Update `tools/term/zsh/config/completion/compdef/_jumps` — this compdef now serves only `j`/`mark-jump`.

## Behavioral Tests

**complete-jumps with marks only:**
- outputs mark entries with name:path format

**complete-jumps with projects only:**
- outputs project entries with name:iconDescription format

**complete-jumps with both:**
- outputs merged list, no duplicates
- project entry wins over mark with same name

**complete-jumps excludes projects without path:**
- projects missing a :path key are not listed

## Acceptance criteria

- [ ] `complete-jumps` outputs merged marks + projects
- [ ] Project entries show icon in description when available
- [ ] Duplicate names resolved in favor of projects
- [ ] Projects without `:path` are excluded
- [ ] `_jumps` compdef only serves `j`/`mark-jump`
- [ ] All behavioral tests pass
