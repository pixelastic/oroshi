# Output

This file defines what each command prints.

## Raw format

`-list-raw` commands display a list of entities in a machine-readable
format, which is then read by `-list`.

The format is defined like this:
- Each entity on its own line.
- Fields are separated by `▮`.
- The values of a multi-value field are separated by `▯`.
- The id always comes in the first column.
- An empty field leaves an empty column.
- A newline inside a value becomes a space.
- An empty listing prints one empty line.

### Example

```text
recA▮Paris Meetup▮2026-03-12▮online▯paris
recB▮Lyon Meetup▮▮
```

See [list-raw.md](commands/list-raw.md) for more details.

## JSON

Commands like `search`, `read`, `create` and `update` are mostly meant to be
used by other commands or by an agent, so they output JSON.

All four print the same format: `read`, `create` and `update` print one
entity, `search` prints an array of entities. The format stays as close as
possible to what the API returns, so that agents can keep following the
documentation of the API. It can be tidied when that makes it easier to read.
Each entity goes through the `format<Entity>` function of the service, which is
the one place that defines it. See
[architecture.md](architecture.md#formatentityjs).

