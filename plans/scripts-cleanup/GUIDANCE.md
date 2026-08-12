# Guidance

## Discoveries

### Issue 03 — Migrate root-level scripts to autoloaded functions
- Many bin scripts already had identical copies in autoload (apt-packages-cache-generate, better-cat, better-ls, better-ydotool, colors, colors-reload, extract) — just needed header conversion and bin deletion
- gif2png already existed as a proper autoloaded function in img/gif/ — bin version was a stale duplicate
- beautysh (used by zsh-lint formatter) cannot parse zsh glob patterns like `*.r([0-9][0-9]))` or `(N)` qualifiers — use `# shellcheck disable` comments to suppress false positives
- `urls` migration deferred per spec (TBD name and domain)
