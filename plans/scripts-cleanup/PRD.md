## Problem Statement

After the first cleanup pass (issues 01-17), `scripts/bin/` still contains ~283 files. Many root-level scripts are unused/dead, and surviving ones need renaming or migration to autoloaded functions. A second interactive audit identified 10 scripts to delete and 6 to rename/migrate.

## Solution

Two-phase cleanup of remaining `scripts/bin/` contents:
1. **Phase A (this plan):** Delete dead root-level scripts + rename/migrate survivors
2. **Phase B (future):** Audit and clean up subdirectory scripts

## Phase A — Root-Level Scripts

### Issue 1: Delete dead root-level scripts

Delete 10 scripts confirmed unused/obsolete during interactive audit:

| Script | Reason |
|--------|--------|
| `foo` | Test script, just `echo $1` |
| `utf8` | Empty (shebang + `set -e` only) |
| `jsclean` | Uses deprecated `fixmyjs`, replaced by eslint/prettier |
| `say` | Depends on `trans` (no longer installed) |
| `dire` | Wrapper around `say --fr`, dead with `say` |
| `kbl` | One-liner gsettings debug, 1 history hit |
| `randomstring` | 1 history hit, `openssl rand` covers the need |
| `throttle` | Buggy, 5 history hits, no dependencies |
| `better-posting` | Posting no longer used; also remove alias in `misc.zsh` |
| `markdown/mk2html` | Perl Markdown original, replaced by `md2html` (pandoc) |

### Issue 2: Rename and migrate surviving scripts

| Current name | New name | Domain | Notes |
|-------------|----------|--------|-------|
| `order` | `rename-prefix-number` | rename/ | Migrate to autoloaded function |
| `rename-sequential` | `rename-number` | rename/ | Already autoloaded, just rename |
| `swapclean` | `swap-clean` | system/ | Migrate to autoloaded function |
| `urls` | TBD | TBD | Keep, name + domain to decide |
| `hx` | `html-get` | html/ | Migrate to autoloaded function |
| `md2html` | `md2html` | markdown/ | Migrate to autoloaded function (keep name) |

## Out of Scope

- Subdirectory scripts audit (Phase B, separate plan)
- Scripts with confirmed dependencies (bin-zsh, colors, extract, compress, etc.)
- Scripts with confirmed high usage (sp, help, record, glob, table, f, g, etc.)
