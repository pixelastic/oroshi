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
- It prints one entity as JSON. Newlines inside values stay untouched.

## Arguments

If the entity can be uniquely identified by a single id, then the id is passed
as a positional argument.
Example: `gmail-read {id}`

If the entity needs to be anchored to a specific parent (a folder, a workspace,
a table, etc) then both the id and the anchor need to be passed as named
arguments.
Example: `airtable-record-read --recordId recXXX --table Meetups`

## Template

### ZSH Wrapper

The wrapper does not parse anything. It forwards `"$@"` to the JS binary.

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

Alternatively, if the entity can't be described with a single id, then all the
required args are passed as an object to the module:

```javascript
const { entityId, anchor } = args;
const output = await entityRead({ entityId, anchor });
```

### Module

The module takes the id (or an object, as seen above) and returns the entity as
data.

`<service>/__lib/<entity>/<entity>Read.js`:

```javascript
import { callApi } from '../callApi.js';

export let __;

/**
 * Read one entity of the service
 * @param {string} entityId - Id of the entity
 * @returns {Promise<object>} The entity, as returned by the API
 */
export async function entityRead(entityId) {
  return await __.callApi({ path: `entities/${entityId}` });
}

__ = {
  callApi,
};
```

### Test

The test covers the module only. It stubs `callApi` through `__` and mostly
checks two things:
- Given a specific id (or object), the module calls `callApi` with the right path and options.
- The returned value is equal to what the API returns.

The zsh wrapper and the node binary are so thin that they need no test.
