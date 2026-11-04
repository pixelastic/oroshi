# `append`

`append` adds some content at the end of the text of an entity, keeps the
existing text, and prints the entity as JSON, in the same format as
[`read`](../../commands/read.md).

## Example

```text
$ notion-page-append --pageId 1f3a '## New section'
```

## Role

- `append` adds. The existing text, with its formatting, keeps its value.
- The content is Markdown, in full: headings, lists, bold, italic and links.
- It prints the entity as it is after the change, as `read` would print it.

## Arguments

The id of the entity is given as in [`read`](../../commands/read.md#arguments).
The content is the positional argument, or a file given with `--content-file`.
The file wins over the positional content, see the
[`-file` suffix](../../../arguments.md#-file-suffix).

```text
$ notion-page-append --pageId 1f3a '## New section'
$ notion-page-append --pageId 1f3a --content-file ./section.md
```

`append` has no [Passage](../README.md#vocabulary) to find, so it never fails on
zero or several matches.

## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-append`:

```zsh
# Add some content at the end of an entity of <service>, and print it as JSON
# The existing content stays
# Usage:
# $ <service>-<entity>-append --<entity>Id <id> '## New section'
# $ <service>-<entity>-append --<entity>Id <id> --content-file ./section.md
# $ <service>-<entity>-append --<entity>Id <id> --content-file ./section.md --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-append.js" "$@"
```

### JS Bin

The bin takes the content as the positional argument, calls the module and
prints the entity as JSON.

`<service>/__lib/bin/<service>-<entity>-append.js`:

```javascript
// <service>-<entity>-append.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { entityAppend } from '../<entity>/<entity>Append.js';
import { setAccount } from '../setAccount.js';

const { positional, named } = parseBinArgs({
  setAccount,
  options: {
    <entity>Id: { type: 'string' },
    content: { type: 'string' },
    'content-file': { type: 'string' },
  },
});
const output = await entityAppend({ content: positional, ...named });
console.log(JSON.stringify(output, null, 2));
```

### Module

The module reads the content, adds it after the existing text and returns the
entity as `read` does.

`<service>/__lib/<entity>/<entity>Append.js`:

```javascript
import { read } from 'firost';
import { callApi } from '../callApi.js';
import { entityRead } from './entityRead.js';

export let __;

/**
 * Add some content at the end of one entity of the service
 * @param {object} options - Id of the entity, and the content
 * @param {string} options.entityId - Id of the entity
 * @param {string} [options.content] - Content to add, as Markdown
 * @param {string} [options.contentFile] - Path to a Markdown file. Wins over content
 * @returns {Promise<object>} The updated entity, as read
 */
export async function entityAppend(options) {
  const { entityId, contentFile } = options;
  const content = contentFile ? await __.read(contentFile) : options.content;

  // Call the API: add the content after the existing text
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

The test lives in `<service>/__lib/<entity>/__tests__/<entity>Append.js`.

The vitest test covers the module only. It mocks `callApi` and `read` through
`__` and checks at least three behaviors:

- Given some content, the module calls `callApi` with it, after the existing
  text.
- A `contentFile` wins over `content`, and its content is added.
- The returned value is the entity, read again after the change.
