## Problem Statement

In "Accept Edits On" mode, Claude asks for confirmation on every `rm`/`rmdir` command because Solkan rejects them (not in the allowlist). Most deletions are safe — the files are committed in HEAD and recoverable via `git checkout`. The constant confirmation noise slows down workflows where Claude needs to clean up, rename, or reorganize files.

## Solution

Route `rm` and `rmdir` through Claude-specific wrappers (`rm-for-claude`, `rmdir-for-claude`) that enforce **safe deletion** before executing. Solkan rewrites command names at the AST level via a new **rewrite list**, so the wrappers receive fully expanded arguments. Safe deletions execute silently; unsafe ones fail with an error directing Claude to `/bin/rm` (which triggers the standard confirmation dialog).

## User Stories

1. As Claude, I want `rm src/old-file.js` to execute silently, so that I don't interrupt the user for a recoverable deletion.
2. As Claude, I want `rm -rf src/deprecated-module/` to execute silently when all files inside are committed in HEAD, so that directory cleanups don't trigger confirmations.
3. As Claude, I want `rm -rf src/module/` to be refused when the directory contains non-recoverable files, so that I don't silently destroy unrecoverable work.
4. As Claude, I want a clear error message when a deletion is refused, so that I know to suggest `/bin/rm` and let the user decide.
5. As the user, I want `rm` in my own CLI to keep going to trash (`rm-for-cli`), so that my personal safety net is unchanged.
6. As the user, I want Claude's unsafe deletions to trigger the standard confirmation dialog via `/bin/rm`, so that I retain the final say.
7. As Claude, I want `rmdir empty-dir/` to execute silently when inside the worktree, so that empty directory cleanup doesn't trigger confirmations.
8. As Claude, I want `rmdir /outside/worktree/` to be refused, so that I can't delete directories outside my workspace.
9. As the user, I want `rm` and `rmdir` rewritten at the AST level (not regex), so that rewrites are precise even in compound commands like `ls && rm foo | grep bar`.
10. As the user, I want the rewrite list to be a simple JSON file alongside the allowlist, so that adding future rewrites is trivial.
11. As Claude, I want `rm` inside quoted strings (e.g. `echo "rm -rf /"`) to NOT be rewritten, so that string arguments are preserved.
12. As the user, I want `rm` on a file outside the git worktree to be refused, so that Claude can't delete system files or files in other worktrees.
13. As the user, I want `rm` on a git-ignored file to be refused, so that build artifacts, tmp files, and caches aren't silently deleted.
14. As the user, I want `rm` on a newly created (never committed) file to be refused, so that work-in-progress that only exists on disk is protected.
15. As Claude, I want the safety check to work with glob-expanded arguments, so that `rm *.test.js` works when all matched files are recoverable.

## Implementation Decisions

### Two sidequests, dependency-ordered

1. **Solkan sidequest** (first): add `--rewrite-list-file` to Solkan. Walks the shell AST, replaces command names per the rewrite map, then runs allowlist validation on the rewritten command. Returns `rewrittenCommand` in JSON output. Exit codes unchanged (0/1).
2. **Oroshi sidequest** (second): builds on Solkan's new feature. Creates the wrapper functions, hook wiring, aliases, and file moves.

### Solkan rewrite

- New CLI flag: `--rewrite-list-file <path>` accepting a JSON map (e.g. `{"rm": "rm-for-claude"}`)
- Rewrite phase runs before allowlist validation — the allowlist sees rewritten commands
- AST-level replacement: only touches command invocations, not strings, comments, or variable names
- Output adds `rewrittenCommand` field to existing JSON structure
- Naming details for solkan's output keys to be finalized during solkan sidequest

### rm-for-claude

- Validates every target path meets **safe deletion** criteria:
  - Path resolves to inside `git rev-parse --show-toplevel`
  - File is **recoverable** (`git cat-file -e HEAD:<relative-path>`)
- For directories with `-r`/`-R`/`--recursive`: batch comparison of `find <dir> -type f` vs `git ls-tree -r --name-only HEAD <dir>`. Any file on disk not in HEAD → refuse.
- No git repo → refuse all deletions
- On success: delegates to `/bin/rm` with original flags and paths
- On failure: prints error to stderr and exits 1
- Error format: `rm-for-claude: cannot delete '<path>' — not committed in HEAD (unrecoverable)\nUse /bin/rm to bypass (requires user approval)`

### rmdir-for-claude

- Validates target is inside the git worktree
- No HEAD check (empty dirs have no files to lose)
- Delegates to `/bin/rmdir`

### rm-for-cli / rmdir-for-cli

- Straight renames of `better-rm` and `better-rmdir`
- Logic unchanged
- Move from `autoload/misc/better/` to `autoload/misc/rm/`

### Hook integration

- `preToolUse-Bash-solkan.zsh`: pass `--rewrite-list-file "${hookDir}/rewrite.json"` to Solkan
- `preToolUse-Bash`: extract `rewrittenCommand` from Solkan JSON, use it as the command for RTK and output
- New file `rewrite.json`: `{"rm": "rm-for-claude", "rmdir": "rmdir-for-claude"}`
- Add `rm-for-claude` and `rmdir-for-claude` to `allowlist.json`

### Alias updates

- `alias rm='rm-for-cli'` (was `rm='better-rm'`)
- `alias rmdir='rmdir-for-cli'` (was `rmdir='better-rmdir'`)

### File structure

```
autoload/misc/rm/
  rm-for-cli
  rm-for-claude
  rmdir-for-cli
  rmdir-for-claude
  __docs/GLOSSARY.md
  __tests/
    rm-for-cli.bats
    rm-for-claude.bats
    rmdir-for-cli.bats
    rmdir-for-claude.bats
```

Old `better-rm` and `better-rmdir` removed from `autoload/misc/better/`.

## Testing Decisions

Tests should verify external behavior: given a git repo state and a command, does the wrapper allow or refuse? No mocking of git internals.

### rm-for-claude tests (deep)
- Committed file → deletes successfully
- Untracked file → refuses with error message
- Git-ignored file → refuses
- Staged but never committed file → refuses
- File outside worktree → refuses
- No git repo → refuses
- Directory with all committed files → deletes
- Directory with one untracked file → refuses
- Multiple files, one unsafe → refuses all (no partial deletion)
- Prior art: `better-rm.bats`, `better-rmdir.bats`

### rmdir-for-claude tests
- Empty dir inside worktree → deletes
- Dir outside worktree → refuses
- No git repo → refuses

### rm-for-cli / rmdir-for-cli tests
- Existing `better-rm.bats` / `better-rmdir.bats` adapted to new function names

### Hook integration tests
- Solkan rewrite + allowlist in one pass → auto-approve with rewritten command
- Mock Solkan to return `rewrittenCommand` in JSON

## Out of Scope

- Solkan implementation (separate sidequest, separate repo)
- Extending safe deletion to other destructive commands (e.g. `mv`, `chmod`)
- Interactive mode for unsafe deletions (Claude gets an error, not a prompt)
- RTK integration with Solkan rewrite (separate concerns)

## Further Notes

- The bypass path (`/bin/rm`) is NOT in the allowlist, so it triggers the standard Solkan rejection → user confirmation dialog. This is the intended escape hatch.
- `rm-for-claude` calls `/bin/rm` (real deletion, no trash) because the safety net is git, not the trash bin. `rm-for-cli` calls `trash-put` because the safety net is the trash bin.
