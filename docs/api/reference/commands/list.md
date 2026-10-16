# `list`

`list` prints the entities of a service as a colored table, for humans to read
in a terminal.

`list` is an exception to the generic rules: it has no bin and no module. Its
wrapper calls [`list-raw`](list-raw.md) and does the rest itself.

## Example

```text
recA  Paris Meetup  2026-03-12  online, paris
recB  Lyon Meetup
```

The columns are aligned. The values of a multi-value field are separated by a
comma.

## Role

- `list` is the human view of [`list-raw`](list-raw.md).
- It displays a `-raw` list in a table with colors and aligned columns.
- It accepts the same flags as `list-raw`.
- It takes its columns from the lines of `list-raw`, whatever their number.

## Arguments

`list` accepts the same flags as [`list-raw`](list-raw.md), and passes them
through.

If the entity has an anchor (like `--baseId` and `--tableId` for an Airtable record), `list-raw`
requires it, and `list` requires it too.

## Colors

Only the id is colored by default. The wrapper colors it with a functional
token.

The developer adds this token to the theme colors source,
`tools/term/zsh/config/theming/src/colors.jsonc`, as a placeholder so more
colors can come later. Then they run `colors-build`.

```jsonc
"<service>": {
  "<entity>-id": "orange"
}
```

### Suggestions

The id is always colored. The other columns depend on the entity, so their
colors are optional. To color a column, the developer adds one token for it,
and the wrapper colors that column with it. For example, to dim the name
column:

```jsonc
"<entity>-name": "gray-3"
```

## Template

### ZSH Wrapper

The wrapper passes its arguments to `list-raw`, then colors the id and aligns
the lines. It reads the columns from the raw lines, whatever their number.

`<service>/<entity>/<service>-<entity>-list`:

```zsh
# List the entities of <service> as a colored table, one row per entity
# For machine consumption, use <service>-<entity>-list-raw
# Usage:
# $ <service>-<entity>-list
# $ <service>-<entity>-list --limit 10
# $ <service>-<entity>-list --account perso
setopt local_options err_return

colors-load-definitions

# The raw command is named like this wrapper, with a -raw suffix
local rawCommand="${0}-raw"

local rawEntities="$($rawCommand "$@")"

# Nothing to display if there is no entity
[[ "$rawEntities" == "" ]] && return 1

local rows=()
for rawEntity in ${(f)rawEntities}; do
  local fields=("${(@ps/▮/)rawEntity}")

  # Color the id. Keep the other columns as they are, and
  # show their multi-values with commas
  local columns=("$(colorize "${fields[1]}" $COLORS[<service>-<entity>-id])")
  columns+=("${(@)fields[2,-1]//▯/, }")

  rows+=("${(j:▮:)columns}")
done

# One row per line, separated by real newlines. `table` splits the columns on ▮
table "${(F)rows}"
```

### Test

The test lives in `<service>/<entity>/__tests__/<service>-<entity>-list.bats`.

`list` has a bats test, because `table` aligns the columns
and the colors depend on the terminal.

The test mocks `list-raw` with canned lines, and covers:
- The flags are passed to `list-raw` as received.
- The rows match the raw lines, with aligned columns.
- Only the id is colored by default.
- An empty listing prints nothing and exits with a non-zero status.
