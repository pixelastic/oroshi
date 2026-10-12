# Arguments

This file defines how a command receives its arguments.

## Parsing

The JavaScript bin parses the arguments with the shared `parseBinArgs` helper
and unpacks them into one options object for the module. The positional
argument and the named flags become its keys: `<entity>Id`, the anchors and the
filters. The wrapper is described in
[architecture.md](architecture.md#zsh-and-javascript).

The bin handles `--account` itself, as defined in
[architecture.md](architecture.md#accounts).

The wrapper lists the accepted arguments in its `# Usage:` header, as defined in
[documentation.md](documentation.md).

## Positional and named

Each command doc lists the exact arguments of its command. These principles
guided the choices:

- The main input of a command is positional: the query of `search`, the id of
  `read`, the content of `create` and `update`.
- Everything else is named: anchors (a table, a space), the id of an entity
  when the content takes the positional slot, filters and options.

```text
$ <service>-<entity>-read recA
$ <service>-<entity>-read recA --baseId appA --tableId Meetups
$ <service>-<entity>-update --<entity>Id recA '{"name":"Paris"}'
```

## Flag names

- A flag that holds an identifier is camelCase, built from the `<entity>` and
  `Id`: `--pageId`, `--recordId`, `--mailId`.
- Every other flag is lowercase kebab-case: `--limit`, `--account`,
  `--data-file`, `--min-date`.

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

### `-file` suffix

Long inputs can be read from a file.

- Fixed schema: a field that can be long also accepts a `-file` twin
  (`--body-file`). The content of the file is used as the value of the field.
- Open schema: `--data-file` replaces the positional JSON. The content of the
  file is parsed as the JSON object.

If both the regular and the `-file` version are passed, the `-file` argument
takes precedence.

```text
$ confluence-page-create --title "Paris Meetup" --body-file ./about.md
$ airtable-record-create --baseId appA --tableId Meetups --data-file ./entity.json
```

## `--limit`

Commands that return several entities (`list-raw`, `search`) accept
`--limit`. The default is 25.

## `--account`

See [architecture.md](architecture.md#accounts).
