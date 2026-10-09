# `list`

`list` prints the entities of a service as a colored table, for humans to read
in a terminal.

## Example

```text
recA  Paris Meetup  2026-03-12  online, paris
recB  Lyon Meetup
```

The id is colored. The columns are aligned. The values of a multi-value field
are separated by a comma.

Entities are displayed in a default order that makes sense for the given
service/entity (usually the most recent first).

## Role

- `list` is the human view of [`list-raw`](list-raw.md).
- It displays a `-raw` list in a table with colors and aligned columns
- It accepts the same flags as `list-raw`.

## Arguments

`list` accepts the same flags as [`list-raw`](list-raw.md), and passes them
through.

If `list-raw` requires some specific argument (like a `--table` anchor for
Airtable), then `list` requires them as well.

## Template

### ZSH Wrapper

The wrapper passes its arguments to `list-raw`, then colors and aligns the
lines.

The `# Usage:` header must contain the list of flags it accepts, mirrored from
the internal JavaScript module.

`<service>/<entity>/<service>-<entity>-list`:

```zsh
# List the entities of <service> as a colored table, one row per entity
# Usage:
# $ <service>-<entity>-list
# $ <service>-<entity>-list --limit 10
setopt local_options err_return

colors-load-definitions

# The raw command is named like this wrapper, with a -raw suffix
local rawCommand="${0}-raw"

local rawEntities="$($rawCommand "$@")"

# Nothing to display if there is no entity
[[ "$rawEntities" == "" ]] && return 0

local output=""
for rawEntity in ${(f)rawEntities}; do
  local fields=("${(@ps/▮/)rawEntity}")
  local entityId="${fields[1]}"
  local entityName="${fields[2]}"
  local entityDescription="${fields[3]}"

  # Color each field, and show the multi-values with commas
  local row=""
  row+="$(colorize "$entityId" $COLORS[<service>-<entity>-id])▮"
  row+="$(colorize "$entityName" $COLORS[<service>-<entity>-name])▮"
  row+="$(colorize "${entityDescription//▯/, }" $COLORS[<service>-<entity>-description])"

  output+="$row\n"
done

table $output
```

### Test

`list` has a bats test, because `table` aligns the columns
and the colors depend on the terminal.

The test mocks `list-raw` with canned lines, and covers:
- The flags are passed to `list-raw` as received.
- The rows match the raw lines, with aligned columns.
- An empty listing prints nothing and exits with zero.
- A failing `list-raw` makes `list` exit with a non-zero status.
