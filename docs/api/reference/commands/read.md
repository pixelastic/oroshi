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
Example: `gmail-read {id}`

If the entity needs to be anchored to a specific parent (a folder, a workspace,
a table, etc) then the anchor is passed as a named argument.
Example: `airtable-record-read recXXX --table Meetups`

## Template

### ZSH Wrapper

The wrapper does not parse anything. It forwards `"$@"` to the bin.

`<service>/<entity>/<service>-<entity>-read`:

```zsh
# Read an entity of <service> by its id, and print it as JSON
# Usage:
# $ <service>-<entity>-read <entity>Id
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-read.js" "$@"
```

### JS Binary

The bin parses the args, unpacks them into what the module expects, calls it and
prints the result as JSON.

`<service>/__lib/bin/<service>-<entity>-read.js`:

```javascript
// <service>-<entity>-read.js
import minimist from 'minimist';
import { entityRead } from '../<entity>/<entity>Read.js';

const args = minimist(process.argv.slice(2));
const entityId = args._[0];
const output = await entityRead(entityId);
console.log(JSON.stringify(output, null, 2));
```

Alternatively, if the entity needs an anchor, the anchor is named and passed to
the module with the id, as an object:

```javascript
const {
  _: [entityId],
  ...anchors
} = args;
const output = await entityRead({ entityId, ...anchors });
```

### Module

The module takes the id (or an object, as seen above) and returns the entity as
data.

`<service>/__lib/<entity>/<entity>Read.js`:

```javascript
import { callApi } from '../callApi.js';
import { formatEntity } from './format<Entity>.js';

export let __;

/**
 * Read one entity of the service
 * @param {string} entityId - Id of the entity
 * @returns {Promise<object>} The entity, formatted
 */
export async function entityRead(entityId) {
  const response = await __.callApi({ path: `entities/${entityId}` });
  return __.formatEntity(response);
}

__ = {
  callApi,
  formatEntity,
};
```

### Test

The test covers the module only. It mocks `callApi` through `__` and mostly
checks two behaviors:
- Given a specific id (or object), the module calls `callApi` with the right path and options.
- The returned value is the response of the API, passed through `formatEntity`.

The zsh wrapper and the bin are so thin that they need no test.
