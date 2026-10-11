# `update`

`update` changes some fields of an existing entity and prints it as JSON, in the
same format as [`read`](read.md).

## Example

```json
{
  "id": "recA",
  "name": "Paris Meetup",
  "date": "2026-03-12",
  "tags": ["online", "paris"]
}
```

## Role

- `update` is a partial update: only the given fields change. The other fields
  keep their value.
- It prints the entity as it is after the update, as `read` would print it.

## Arguments

The content follows the schema of the entity, see
[Passing content](../../arguments.md#passing-content).

```text
# Fixed schema
$ confluence-page-update --pageId 1f3a --title "Paris Meetup 2026"

# Open schema
$ notion-page-update --pageId 1f3a --data-file ./changes.json
```

## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-update`:

```zsh
# Update some fields of an entity of <service>, and print it as JSON
# Only the given fields change
# Usage:
# $ <service>-<entity>-update --<entity>Id <id> --title "Paris Meetup 2026"
# $ <service>-<entity>-update --<entity>Id <id> '{"seats":90}'
# $ <service>-<entity>-update --<entity>Id <id> --data-file ./<entity>.json
# $ <service>-<entity>-update --<entity>Id <id> --title "Paris" --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-update.js" "$@"
```

### JS Bin

The bin parses the args, calls the module and prints the entity as JSON.

`<service>/__lib/bin/<service>-<entity>-update.js`:

```javascript
// <service>-<entity>-update.js
import minimist from 'minimist';
import { entityUpdate } from '../<entity>/<entity>Update.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The content is the positional argument (open schema), or the named fields.
// The id is named
const {
  _: [content],
  account,
  ...options
} = args;
setAccount(account);
const output = await entityUpdate({ content, ...options });
console.log(JSON.stringify(output, null, 2));
```

### Module

The module takes the id and the content as one options object and returns the
updated entity.

`<service>/__lib/<entity>/<entity>Update.js`:

```javascript
import { callApi } from '../callApi.js';
import { formatEntity } from './format<Entity>.js';

export let __;

/**
 * Update some fields of one entity of the service
 * @param {object} options - Id of the entity, and the fields to change
 * @param {string} options.entityId - Id of the entity
 * @returns {Promise<object>} The updated entity, formatted
 */
export async function entityUpdate(options) {
  // Build the content from the options (JSON, --data-file or named fields)

  // Transform the content into the body of the API call, with only the fields
  // to change

  // Call the API: the path first, then the method and the body
  await __.callApi(path, { method, body });

  // Return the updated entity, passed through __.formatEntity
}

__ = {
  callApi,
  formatEntity,
};
```

### Test

The test lives in `<service>/__lib/<entity>/__tests__/<entity>Update.js`.

The vitest test covers the module only. It mocks `callApi` through `__` and
mostly checks three behaviors:
- Given an id and some fields, the module calls `callApi` with the right method,
  path and body.
- The body holds only the given fields, and never the id.
- The returned value is the response of the API, passed through `formatEntity`.

The zsh wrapper and the bin are so thin that they need no test.
