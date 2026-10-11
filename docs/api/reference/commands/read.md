# `read`

`read` takes the id of an entity and prints that entity as JSON, with all its
fields.

## Example

```json
{
  "id": "recA",
  "name": "Paris Meetup",
  "date": "2026-03-12",
  "tags": ["online", "paris"],
  "description": "Line one\nLine two"
}
```

## Role

- `read` takes an id returned by [`list-raw`](list-raw.md) (first column) or found in the output of [`search`](search.md).
- It prints one entity as JSON, formatted per `format<Entity>`.

## Arguments

The id is always a positional argument.
Example: `gmail-mail-read {id}`

If the entity needs an anchor (a folder, a workspace, a table, etc), `read`
requires it as a named argument.
Example: `airtable-record-read recXXX --table Meetups`

## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-read`:

```zsh
# Read an entity of <service> by its id, and print it as JSON
# Usage:
# $ <service>-<entity>-read <entity>Id
# $ <service>-<entity>-read <entity>Id --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-read.js" "$@"
```

### JS Bin

The bin parses the args, unpacks them into one options object (the id, the
anchors if any), calls the module and prints the result as JSON.

`<service>/__lib/bin/<service>-<entity>-read.js`:

```javascript
// <service>-<entity>-read.js
import minimist from 'minimist';
import { entityRead } from '../<entity>/<entity>Read.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument, the anchors are named
const {
  _: [entityId],
  account,
  ...options
} = args;
setAccount(account);
const output = await entityRead({ entityId, ...options });
console.log(JSON.stringify(output, null, 2));
```

### Module

The module takes one options object and returns the entity as data.

`<service>/__lib/<entity>/<entity>Read.js`:

```javascript
import { callApi } from '../callApi.js';
import { formatEntity } from './format<Entity>.js';

export let __;

/**
 * Read one entity of the service
 * @param {object} options - Id of the entity, and its anchors if any
 * @param {string} options.entityId - Id of the entity
 * @returns {Promise<object>} The entity, formatted
 */
export async function entityRead(options) {
  const { entityId } = options;

  // Call the API, with the id of the entity
  const response = await __.callApi(`entities/${entityId}`);
  return __.formatEntity(response);
}

__ = {
  callApi,
  formatEntity,
};
```

### Test

The test lives in `<service>/__lib/<entity>/__tests__/<entity>Read.js`.

The vitest test covers the module only. It mocks `callApi` through `__` and mostly
checks two behaviors:
- Given an id, the module calls `callApi` with the right path.
- The returned value is the response of the API, passed through `formatEntity`.

The zsh wrapper and the bin are so thin that they need no test.
