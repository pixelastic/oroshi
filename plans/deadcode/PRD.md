## Problem Statement

The repo contains accumulated dead code from past technology migrations: VimScript files superseded by Lua, `__legacy` folders (Docker helpers, image processing) whose Ruby originals were rewritten in Zsh, and Ruby test files that are broken or empty. This dead code adds noise, increases cognitive load when navigating the repo, and could mislead future contributors into thinking these files are still in use.

## Solution

Systematically identify and remove dead code across four areas, with a **mandatory pre-deletion verification step** for any deletion that could break still-active scripts. Deletions are grouped by risk: zero-risk (delete directly) vs. needs-verification (grep for cross-references first).

## User Stories

1. As a developer, I want `oroshi-old.vim` removed, so that the colorscheme folder only contains the active Lua implementation.
2. As a developer, I want to verify no active Docker scripts reference anything inside `docker/__legacy` before deleting it, so that the Docker tooling is not silently broken.
3. As a developer, I want to verify no active image scripts or ZSH autoload functions reference anything inside `img/__legacy` before deleting it, so that image processing workflows are not broken.
4. As a developer, I want two broken/empty Ruby test files in `music-metadata-update/tests/` removed directly, so that the test folder only contains valid, runnable tests.
5. As a developer, I want empty parent directories cleaned up automatically after their contents are deleted, so that the folder tree stays tidy.

## Implementation Decisions

### Module 1 — vim-cleanup (zero risk, delete directly)
- Delete `oroshi-old.vim` only. The colorscheme has a complete Lua equivalent.
- `vimium-mappings.vim` is **kept** (still referenced by the Firefox install script).

### Module 2 — docker-legacy-cleanup (needs verification)
- Before deleting `docker/__legacy/`, grep for references to each script name it contains across:
  - All other scripts in `scripts/bin/docker/` (outside `__legacy`)
  - All ZSH autoload functions
- Only proceed with deletion if no live references are found.
- If live references exist, document them before touching anything.

### Module 3 — img-legacy-cleanup (needs verification)
- Before deleting `img/__legacy/`, grep for references to each script/lib name it contains across:
  - All other scripts in `scripts/bin/img/` (outside `__legacy`)
  - All ZSH autoload functions
- Only proceed with deletion if no live references are found.
- If live references exist, document them before touching anything.

### Module 4 — ruby-dead-cleanup (zero risk, delete directly)
- Delete `music-metadata-update/tests/mp3.test.rb` (broken `require` to a non-existent file).
- Delete `music-metadata-update/tests/music-metadata-update.test.rb` (empty template).
- If the `tests/` directory is empty after deletion, delete it too.
- `compression_helper.rb` (empty file in `img/__legacy`) is covered by Module 3.

### General rule — empty directory cleanup
After any deletion, if the immediate parent directory is left empty, delete it as well.

## Testing Decisions

This PRD covers pure deletion. No new code is written, so no new tests are needed.

The verification step in Modules 2 and 3 acts as a manual pre-flight check (grep-based), ensuring that nothing currently live references what is about to be deleted. This verification must be documented (output captured) before deletion proceeds.

## Out of Scope

- `vimium-mappings.vim` — kept intentionally.
- `html2pdf` Ruby script — kept intentionally.
- `gem-helper.rb` — kept intentionally (uncertain usage, not worth the risk).
- `__pdf/` scripts and libs — not touched (actively used by 20+ scripts).
- Any refactoring of the remaining Docker or image scripts.
- Migration of any legacy logic to Zsh before deletion.

## Further Notes

- All deleted files remain recoverable via git history.
- Modules 2 and 3 share the same verification pattern: enumerate filenames inside `__legacy`, grep for those names across the live codebase, confirm zero hits, then delete.
- If any cross-reference is found during verification, that specific file should be excluded from deletion and flagged for separate investigation.
