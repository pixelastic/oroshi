## TLDR

Detect per-repo `.claude/allow-list.json` and `.claude/rewrite-list.json` and pass them as extra flags to solkan.

## What to build

Modify `preToolUse-Bash-solkan()` in `tools/ai/claude/config/hooks/preToolUse-Bash-solkan.zsh` to:

1. Get the repo root via `git-directory-root`
2. Check if `.claude/allow-list.json` exists at that root — if so, add an extra `--allow-list-file` flag
3. Check if `.claude/rewrite-list.json` exists at that root — if so, add an extra `--rewrite-list-file` flag
4. Each file is checked independently

The solkan call goes from:

```
solkan --allow-list-file <global> --rewrite-list-file <global> "$1"
```

to (when both local files exist):

```
solkan --allow-list-file <global> --allow-list-file <local> --rewrite-list-file <global> --rewrite-list-file <local> "$1"
```

Depends on solkan multi-file support (separate sidequest).

## Behavioral Tests

**Local allow-list present:**
- allows a command that is only in the local allow-list
- rejects a command that is in neither global nor local allow-list
- allows a command that is in the global allow-list (unchanged behavior)

**Local rewrite-list present:**
- rewrites a command that is only in the local rewrite-list

**No local files:**
- behaves identically to before (no git-directory-root call needed, or call is harmless)

**Only one local file:**
- allow-list without rewrite-list works
- rewrite-list without allow-list works

## Acceptance criteria

- [ ] `preToolUse-Bash-solkan()` detects repo root via `git-directory-root`
- [ ] Extra `--allow-list-file` passed when `.claude/allow-list.json` exists
- [ ] Extra `--rewrite-list-file` passed when `.claude/rewrite-list.json` exists
- [ ] Each local file checked independently
- [ ] Bats tests cover: local-only command allowed, no-local-file unchanged, one-file-without-other
- [ ] No race conditions across parallel sessions (no shared temp files)
