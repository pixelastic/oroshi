# `remove`

`remove` deletes one passage of the text of an entity, and prints the entity as
JSON, in the same format as [`read`](../../commands/read.md). The entity stays:
use [`delete`](../../commands/delete.md) to remove the entity itself.

## Example

```text
$ notion-page-remove --pageId 1f3a --old 'Obsolete paragraph'
```

## Role

- `remove` deletes one passage. The rest of the text keeps its value.
- It prints the entity as it is after the change, as `read` would print it.

## Arguments

`remove` requires the id and the old passage of
[`replace`](replace.md#arguments): `--old` and `--old-file`. It has no `--new`
and no `--new-file`.

The passage follows the [contract of `replace`](replace.md#passage): Markdown
text that must appear exactly once, or the command fails and changes nothing.

```text
$ notion-page-remove --pageId 1f3a --old 'Obsolete paragraph'
$ notion-page-remove --pageId 1f3a --old-file ./old.md
```

## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-remove`:

```zsh
# Delete one passage of an entity of <service>, and print it as JSON
# <Service> fails if the passage is missing or appears several times
# Usage:
# $ <service>-<entity>-remove --<entity>Id <id> --old 'Obsolete paragraph'
# $ <service>-<entity>-remove --<entity>Id <id> --old-file ./old.md
# $ <service>-<entity>-remove --<entity>Id <id> --old 'Obsolete paragraph' --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-remove.js" "$@"
```

### JS Bin

The bin is the one of [`replace`](replace.md#js-bin), without the two `new`
flags.

### Module

The module of `remove` calls the module of [`replace`](replace.md#module) with
an empty new passage. A service can skip this module, and the bin then calls
`replace` itself.

### Test

If `remove` has its own module, its test mocks `replace` through `__` and checks
that the module passes the id and the old passage with an empty new passage. A
service with no such module needs no test for `remove`.
