## Problem Statement

After the first cleanup pass (issues 01-17), `scripts/bin/` still contains ~283 files. Many root-level scripts are unused/dead, and surviving ones need renaming or migration to autoloaded functions. A second interactive audit identified scripts to delete, rename, and migrate.

## Solution

Two-phase cleanup of remaining `scripts/bin/` contents:
1. **Phase A (this plan):** Delete dead root-level scripts + rename/migrate survivors
2. **Phase B (future):** Audit and clean up subdirectory scripts

## Phase A — Root-Level Scripts

### Issue 1: Delete dead root-level scripts

Delete 13 scripts confirmed unused/obsolete:

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
| `better-posting` | Posting no longer used |
| `markdown/mk2html` | Perl Markdown original, replaced by `md2html` (pandoc) |
| `compress` | Ruby dependency (`etc/compress/`) deleted, script is dead |
| `record` | Ruby + X11 (byzanz-record/xprop/wmctrl), broken on Wayland |
| `help` | 0 real history hits (489 were `--help` false positives) |

### Issue 2: Rename root-level scripts

| Current | New name | Notes |
|---------|----------|-------|
| `f` | `better-find` + alias `f` | fd wrapper |
| `g` | `better-grep` + alias `g` | rg wrapper |
| `header` | `http-header` | Domain http/ |
| `http/post` | `http-post` | Domain http/ |
| `sp` | `spotify-dbus` | Move into spotify/, stays as bash script |
| `chmod-default` | `chmod-default` | Rewrite Ruby to ZSH, find domain |

### Issue 3: Migrate root-level scripts to autoloaded functions

| Script | Target domain | Notes |
|--------|--------------|-------|
| `apt-packages-cache-generate` | apt-get/ | Already ZSH |
| `better-cat` | (root or misc/) | Already ZSH |
| `better-ls` | (root or misc/) | Already ZSH |
| `better-ydotool` | (root or misc/) | Already ZSH |
| `colors` | (root or system/) | Already ZSH |
| `colors-reload` | (root or system/) | Already ZSH |
| `extract` | (root or misc/) | Already ZSH |
| `gif2png` | img/ | Already ZSH |
| `glob` | (root or misc/) | Already ZSH |
| `table` | (root or misc/) | Already ZSH |
| `watch-and-reload` | (root or misc/) | Already ZSH |
| `order` | rename/ | Rewrite Ruby to ZSH, rename to `rename-prefix-number` |
| `rename-sequential` | rename/ | Already autoloaded, rename to `rename-number` |
| `swapclean` | system/ | Rename to `swap-clean` |
| `hx` | html/ | Rename to `html-get` |
| `md2html` | markdown/ | Keep name |
| `urls` | TBD | Name + domain to decide |

### Scripts that remain as scripts

| Script | Reason |
|--------|--------|
| `bin-zsh` | Core dispatcher, called from non-ZSH contexts |
| `spotify-dbus` (ex `sp`) | Bash, third-party, not convertible |
| `spotify/*` wrappers | Bash, called from keybindings |

## Out of Scope

- Subdirectory scripts audit (Phase B, separate plan)
- exa to eza migration (separate task)
