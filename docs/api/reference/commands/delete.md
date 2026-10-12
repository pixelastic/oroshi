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

## Arguments

The id is a positional argument, and the anchor (if any) is named, as in
[`read`](read.md#arguments).

## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-delete`:

```zsh
# Delete an entity of <service> by its id, and print the id
# Usage:
# $ <service>-<entity>-delete <entity>Id
# $ <service>-<entity>-delete <entity>Id --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-delete.js" "$@"
```

### JS Bin

The bin parses the args, unpacks them into what the module expects, calls it and
prints the id as is.

`<service>/__lib/bin/<service>-<entity>-delete.js`:

```javascript
// <service>-<entity>-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { entityDelete } from '../<entity>/<entity>Delete.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument, the anchor (if any) is named
const { positional, named } = parseBinArgs({ setAccount });
const output = await entityDelete({ entityId: positional, ...named });
console.log(output);
```

### Module

The module takes one options object and returns the id it removed.

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
  await __.callApi(`entities/${entityId}`, { method: 'DELETE' });

  // Return the id
  return entityId;
}

__ = {
  callApi,
};
```

### Test

The test lives in `<service>/__lib/<entity>/__tests__/<entity>Delete.js`.

The vitest test covers the module only. It mocks `callApi` through `__` and
mostly checks two behaviors:
- Given an id, the module calls `callApi` with the `DELETE` method and the right
  path.
- The returned value is the id it received.

The zsh wrapper and the bin are so thin that they need no test.
