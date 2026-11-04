# `replace`

`replace` swaps one passage of the text of an entity for another passage, and
prints the entity as JSON, in the same format as
[`read`](../../commands/read.md).

`replace` is one of the three custom verbs of a [Page](../README.md).

## Example

```text
$ notion-page-replace --pageId 1f3a --old 'Pariss' --new 'Paris'
```

## Role

- `replace` changes one passage. The rest of the text keeps its value.
- It prints the entity as it is after the change, as `read` would print it.

## Arguments

The id of the entity is the named flag `--<entity>Id`. The passages are named,
and follow the [`-file` suffix](../../../arguments.md#-file-suffix) rule.

The id and both passages are required: `--old` or `--old-file`, and `--new` or
`--new-file`. The command fails and changes nothing when one is missing. An
empty old passage counts as a missing one. An empty new passage is valid.

| Flag         | Role                                                                    |
| ------------ | ----------------------------------------------------------------------- |
| `--old`      | The passage to find, as Markdown                                        |
| `--old-file` | A file that holds the passage to find. It takes precedence over `--old` |
| `--new`      | The passage to put instead, as Markdown                                 |
| `--new-file` | A file that holds the passage to put. It takes precedence over `--new`  |

```text
$ notion-page-replace --pageId 1f3a --old 'Pariss' --new 'Paris'
$ notion-page-replace --pageId 1f3a --old-file ./old.md --new-file ./new.md
```

## Passage

The contract of the old passage is the same for all services:

- The old passage is Markdown text.
- It must appear exactly once in the text. The command fails when it appears
  zero times, and fails when it appears several times. A failed command changes
  nothing.
- To insert text in the middle, repeat the old passage in the new one.

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
`__` and checks at least three behaviors:

- Given `old` and `new`, the module calls `callApi` with both passages.
- A `oldFile` or a `newFile` wins over `old` or `new`, and its content is the
  passage.
- The returned value is the entity, read again after the change.
