# ZSH Style

## Essentials

- Remove duplication by extracting helpers
- Improve readability with clear names. Avoid abbreviations (`absolutePath` not `absPath`)
- Return early to avoid `if/else` nesting (see [Conditions](./conditions.md))
- Write comments that say only what the code shows, and link facts with because, so, but

## Return early

**Before:**

```zsh
local filepath="$1"
if [[ -f "$filepath" ]]; then
  if [[ "$filepath" == *.zsh ]]; then
    return 0
  else
    local firstLine="$(head -1 "$filepath")"
    if [[ "$firstLine" == "#!/usr/bin/env zsh" ]]; then
      return 0
    fi
  fi
fi
return 1
```

**After:**

```zsh
local filepath="$1"

# Non-regular files
[[ ! -f "$filepath" ]] && return 1

# .zsh extension
[[ "$filepath" == *.zsh ]] && return 0

# No extension: check for zsh shebang
local firstLine="$(head -1 "$filepath")"
[[ "$firstLine" == "#!/usr/bin/env zsh" ]] && return 0

return 1
```

## Comments

Follow [Comments](./comments.md). Write comments with `#`. Function docs are a comment block above the function.

## Naming scripts

- Scripts in `$PATH` tend to follow a `{domain}-{subdomain?}-{action}` naming scheme (eg. `docker-image-list`).
- `{subdomain}` can be omitted if the intent is clear enough (eg `png-min`)
- `is-*` give no output and return a boolean with an exit code 0/1 (eg `is-zsh`)
- `*-exists` give no output and return a boolean with an exit code 0/1 (eg `git-branch-exists`)
- `*-list-raw` outputs machine readable list, one item per line, fields separated by `▮` (eg `git-branch-list-raw`)
- `*-list` outputs human readable list, colored, table aligned, consuming `*-list-raw` (eg `git-branch-list`)

## Structure

1. Header comment (see [Header](./header.md))
2. `setopt local_options err_return` (lint-enforced)
3. (optional) `source` of `__lib/` files, via `"${functions_source[$0]:A:h}/__lib/…"`
4. `zparseopts`, then flags → named locals (see [Args Parsing](./args-parsing.md))
5. `*-load-definitions` calls (`colors`, `icons`, …) (lint-enforced)
6. Input guards (missing args, empty input)
7. Main body
8. Output
