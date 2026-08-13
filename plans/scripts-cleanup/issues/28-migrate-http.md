## TLDR

Migrate `http-header` and `http-post` from `scripts/bin/http/` to autoloaded functions in `misc/http/`.

## What to build

Create new subdomain `tools/term/zsh/config/functions/autoload/misc/http/`.

Migrate `http-header`:
- Rewrite from bash to zsh autoload format
- Remove shebang, add header comment with usage
- Add `setopt local_options err_return`
- Quote the `$1` argument in the curl call

Migrate `http-post`:
- Remove shebang
- Replace `set -e` with `setopt local_options err_return`
- Keep existing logic (already zsh)

Delete originals from `scripts/bin/http/`.

## Behavioral Tests

**http-header:**
- Returns HTTP headers for a given URL

**http-post:**
- Makes POST request with JSON file body

## Acceptance criteria

- [ ] `http-header` exists as autoloaded function in `misc/http/`
- [ ] `http-post` exists as autoloaded function in `misc/http/`
- [ ] Both pass `zsh-lint`
- [ ] Original scripts deleted from `scripts/bin/http/`
