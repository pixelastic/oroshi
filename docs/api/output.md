# Output

This file defines the type of displayed output of each commands.

## Raw format

`-list-raw` commands display a list if `<entities>` in a machine-readable
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

Commands like `search` and `read` are mostly meant to be used by other scripts
ot by an agent, so they output JSON.

