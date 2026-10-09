# `delete`

`delete` removes one entity from a service and prints the id of the entity it
removed.

## Example

```text
recA
```

## Role

- `delete` removes one entity, identified by its id.
- It prints the id it received, so that the output confirms what was removed.
- A service has a `delete` command only if it decides it needs one. Most
  services do not.

## Arguments

The id is a positional argument, and the anchor (if any) is named, as in
[`read`](read.md#arguments).

## Template

### ZSH Wrapper

The wrapper does not parse anything. It forwards `"$@"` to the bin.

`<service>/<entity>/<service>-<entity>-delete`:

```zsh
# Delete an entity of <service> by its id, and print the id
# Usage:
# $ <service>-<entity>-delete <entity>Id
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-delete.js" "$@"
```

### JS Binary

The bin parses the args, unpacks them into what the module expects, calls it and
prints the id as is.

`<service>/__lib/bin/<service>-<entity>-delete.js`:

```javascript
// <service>-<entity>-delete.js
import minimist from 'minimist';
import { entityDelete } from '../<entity>/<entity>Delete.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument, the anchor (if any) is named
const {
  _: [entityId],
  ...anchor
} = args;
const output = await entityDelete({ entityId, ...anchor });
console.log(output);
```

### Module

The module takes the id and the anchor as one options object and returns the
id it removed.

`<service>/__lib/<entity>/<entity>Delete.js`:

```javascript
import { callApi } from '../callApi.js';

export let __;

/**
 * Delete one entity of the service
 * @param {object} options - Id of the entity, and its anchor if any
 * @param {string} options.entityId - Id of the entity
 * @returns {Promise<string>} The id of the removed entity
 */
export async function entityDelete(options) {
  const { entityId } = options;

  // Call the API, with the id of the entity
  await __.callApi({ method: 'DELETE', path: `entities/${entityId}` });

  // Return the id
  return entityId;
}

__ = {
  callApi,
};
```

### Test

The vitest test covers the module only. It mocks `callApi` through `__` and
mostly checks two behaviors:
- Given an id, the module calls `callApi` with the `DELETE` method and the right
  path.
- The returned value is the id it received.

The zsh wrapper and the bin are so thin that they need no test.
