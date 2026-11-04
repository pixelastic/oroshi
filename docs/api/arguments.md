# Arguments

This file defines how a command receives its arguments.

## Parsing

The JavaScript bin parses the arguments with the shared `parseBinArgs` helper
and unpacks them into one options object for the module. The positional argument
and the named flags become its keys: the main input (`<entity>Id`, `query` or
`content`), the anchors and the filters. The wrapper is described in
[architecture.md](architecture.md#zsh-and-javascript).

The bin handles `--account` itself, as defined in
[architecture.md](architecture.md#accounts).

## Positional and named

Each command doc lists the exact arguments of its command. These principles
guided the choices:

- The main input of a command is positional: the query of `search`, the id of
  `read` and `delete`, the content of `create` and `update`.
- Everything else is named: anchors (a table, a space), the id of an entity for
  the commands that take content or passages (`update`, `append`, `replace`,
  `remove`), filters and any other flag.

```text
$ <service>-<entity>-read recA
$ <service>-<entity>-read recA --baseId appA --tableId Meetups
$ <service>-<entity>-update --<entity>Id recA '{"name":"Paris"}'
```

## Flag names

- A flag that holds an identifier is camelCase, built from the `<entity>` and
  `Id`: `--pageId`, `--recordId`, `--messageId`.
- Every other flag is lowercase kebab-case: `--limit`, `--account`,
  `--data-file`, `--date-min`.

## Passing content

Commands like `create` and `update` receive the content of an entity. Each
entity uses one of two modes, chosen when the entity is added and noted in the
glossary of the service.

- **Fixed schema**: each field is a named flag, like `--title` and `--body`.
  There is no `--data`.
- **Open schema**: the whole content is a JSON object, passed as the positional
  argument. There is no field flag.

```text
$ confluence-page-create --title "Paris Meetup"
$ airtable-record-create --baseId appA --tableId Meetups '{"title":"Paris Meetup","seats":80}'
```

### Required and empty fields

A required field is one that the API requires, or one that a generic entity type
defines (a Page needs a title).

- `create`: every required field must be present and not empty.
- `update`: only the given fields change. A required field cannot be set to an
  empty value. An optional field set to an empty value is cleared.
- Otherwise the command fails and changes nothing. `update` with no field at all
  fails too.

### `-file` suffix

Long or hard-to-escape inputs can be read from a file.

- Fixed schema: a field also accepts a `-file` twin (`--body-file`) when its
  value can span several lines, or can hold characters that are hard to escape
  in a shell (quotes, backticks, `$`). The content of the file is used as the
  value of the field, as it is: nothing is trimmed, not even the final newline.
- Open schema: `--data-file` replaces the positional JSON. The content of the
  file is parsed as the JSON object.

If both the regular and the `-file` version are passed, the `-file` argument
takes precedence.

```text
$ confluence-page-create --title "Paris Meetup" --body-file ./about.md
$ airtable-record-create --baseId appA --tableId Meetups --data-file ./entity.json
```

## `--limit`

Commands that return several entities (`list-raw`, `search`) accept `--limit`.
`--limit` is a positive integer. The default is 25. Any other value fails with
`<SERVICE>_INVALID_ARGUMENT`.

`--limit` caps the entities the command returns, after the query and every
filter. The module applies the query and the filters itself when the API cannot.

## Missing and invalid arguments

A command fails with `<SERVICE>_MISSING_ARGUMENT` when a required argument is
missing or empty: the id, an anchor, the content, a passage or a required field.

A command fails with `<SERVICE>_INVALID_ARGUMENT` when an argument is present
but invalid: a `--limit` that is not a positive integer, or a JSON that does not
parse.

In both cases, the message names the argument. The command fails before it calls
the API, and changes nothing.

## `--account`

See [architecture.md](architecture.md#accounts).
