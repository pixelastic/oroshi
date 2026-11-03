# `replace`

`replace` swaps one passage of the text of an entity for another passage, and
prints the entity as JSON, in the same format as [`read`](read.md).

This file holds the contract shared by [`replace`](replace.md),
[`remove`](remove.md) and [`append`](append.md). The other two link here and do
not repeat it.

## Example

```text
$ notion-page-replace --pageId 1f3a --old 'Pariss' --new 'Paris'
```

## Role

- `replace` changes one passage. The rest of the text keeps its value.
- It prints the entity as it is after the change, as `read` would print it.

## Arguments

The id of the entity is given as in [`read`](read.md#arguments). The passages
are named, and follow the [`-file` suffix](../../arguments.md#-file-suffix)
rule.

| Flag         | Role                                                   |
| ------------ | ------------------------------------------------------ |
| `--old`      | The passage to find, as Markdown                       |
| `--old-file` | A file that holds the passage to find. It wins `--old` |
| `--new`      | The passage to put instead, as Markdown                |
| `--new-file` | A file that holds the passage to put. It wins `--new`  |

```text
$ notion-page-replace --pageId 1f3a --old 'Pariss' --new 'Paris'
$ notion-page-replace --pageId 1f3a --old-file ./old.md --new-file ./new.md
```

## Passage

The contract of a passage is the same for all services:

- A passage is Markdown text.
- The old passage must appear exactly once in the text. The command fails when
  it appears zero times, and fails when it appears several times. A failed
  command changes nothing.
- To insert text in the middle, repeat the old passage in the new one.

### Limits of a service

A service can narrow the contract, and says so in the header of its wrappers.
Google Docs adds these limits:

- The Document is the positional argument, not a named `--<entity>Id`.
- `--old` is plain text, in one paragraph. It cannot span a paragraph break or
  an image, and it cannot be found inside a table. An empty `--old` fails.
- `--new` is inline Markdown only: bold, italic, code and links. A heading or a
  list is plain text there. `append` reads full Markdown.

## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-replace`:

```zsh
# Swap one passage of an entity of <service> for another, and print it as JSON
# <Service> fails if the old passage is missing or appears several times
# To insert in the middle, repeat the old passage in the new one
# Usage:
# $ <service>-<entity>-replace --<entity>Id <id> --old 'Pariss' --new 'Paris'
# $ <service>-<entity>-replace --<entity>Id <id> --old-file ./old.md --new-file ./new.md
# $ <service>-<entity>-replace --<entity>Id <id> --old 'Pariss' --new 'Paris' --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-replace.js" "$@"
```

### JS Bin

The bin declares the four passage flags as strings, so that a passage that looks
like a number stays a string.

`<service>/__lib/bin/<service>-<entity>-replace.js`:

```javascript
// <service>-<entity>-replace.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { entityReplace } from '../<entity>/<entity>Replace.js';
import { setAccount } from '../setAccount.js';

const { named } = parseBinArgs({
  setAccount,
  options: {
    <entity>Id: { type: 'string' },
    old: { type: 'string' },
    'old-file': { type: 'string' },
    new: { type: 'string' },
    'new-file': { type: 'string' },
  },
});
const output = await entityReplace(named);
console.log(JSON.stringify(output, null, 2));
```

### Module

The module reads the passages, changes the entity and returns it as `read` does.

`<service>/__lib/<entity>/<entity>Replace.js`:

```javascript
import { read } from 'firost';
import { callApi } from '../callApi.js';
import { entityRead } from './entityRead.js';

export let __;

/**
 * Swap one passage of one entity of the service for another passage
 * The service throws if the old passage is missing, or appears several times
 * @param {object} options - Id of the entity, and the passages
 * @param {string} options.entityId - Id of the entity
 * @param {string} [options.old] - Passage to find, as Markdown
 * @param {string} [options.oldFile] - Path to a Markdown file. Wins over old
 * @param {string} [options.new] - Passage to put instead, as Markdown
 * @param {string} [options.newFile] - Path to a Markdown file. Wins over new
 * @returns {Promise<object>} The updated entity, as read
 */
export async function entityReplace(options) {
  const { entityId, oldFile, newFile } = options;
  const oldPassage = oldFile ? await __.read(oldFile) : options.old;
  const newPassage = newFile ? await __.read(newFile) : options.new;

  // Call the API: find the one old passage, and put the new one instead
  await __.callApi(path, { method, body });

  return await __.entityRead({ entityId });
}

__ = {
  callApi,
  entityRead,
  read,
};
```

### Test

The test lives in `<service>/__lib/<entity>/__tests__/<entity>Replace.js`.

The vitest test covers the module only. It mocks `callApi` and `read` through
`__` and mostly checks three behaviors:

- Given `old` and `new`, the module calls `callApi` with both passages.
- A `oldFile` or a `newFile` wins over `old` or `new`, and its content is the
  passage.
- The returned value is the entity, read again after the change.

The zsh wrapper and the bin are so thin that they need no test.
