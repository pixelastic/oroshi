# Arguments

This file defines how a command receives its arguments.

## Parsing

The ZSH wrapper does not parse anything. It forwards `"$@"` to the JavaScript
bin, which parses the arguments with `minimist` and passes the result to the
module.

The wrapper still lists the accepted arguments in its `# Usage:` header. The
header mirrors what the JavaScript module accepts. It is the text that
`helper-list` shows, so keep both in sync.

## Positional and named

- If there is only one required argument, make it positional.
- If there are several required arguments, make them all named.
- Optional arguments are always named.

```text
$ <service>-<entity>-read recA
$ <service>-<entity>-update --<entity>Id recA --data '{"name":"Paris"}'
```

The first call has one required argument: the id is positional. The second
call has two (the id and the content): both are named.

## Flag names

- A flag that holds an identifier is camelCase, built from the `<entity>` and
  `Id`: `--pageId`, `--recordId`, `--mailId`.
- Every other flag is lowercase: `--file`, `--limit`, `--account`.

## Passing data

Helpers like `-create` or `-update` that need to pass data can have one of two
shapes:

- `--data` (default): Accepts a JSON object that contains the whole data
OR
- Dedicated fields: like `--title` and `--status` if the shape is simple enough

```text
$ confluence-page-create --title "Paris Meetup"
$ airtable-record-create --data '{"title":"Paris Meetup","seats":80}'
```

### `-file` suffix

Long inputs, like an Airtable record `--data` or a Gmail message `--body` can
also be passed with a `-file` suffix (`--data-file` or `--body-file`).

In that case the content of the specified filepath is read and used as the
value.

If both the regular and the `-file` suffixed version are passed, the `-file`
argument takes precedence.


```text
$ confluence-page-create --title "Paris Meetup" --body-file ./about.md
$ airtable-record-create --data-file ./entity.json
```

## `--limit`

Commands that return several entities (`list-raw`, `search`) accept `--limit`.

- The default is 25.
- If a default API call can get that many items, the module needs to internally
  handle pagination to get to the `--limit` value.

## `--account`

Some services can be used with several accounts. The default account is always
used, but can be overriden with `--account <accountName>`.

How accounts and their tokens work is defined in [architecture.md](architecture.md#accounts).
