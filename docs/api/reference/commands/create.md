# `create`

`create` makes a new entity in a service and prints it as JSON, in the same
format as [`read`](read.md).

## Example

```json
{
  "id": "recC",
  "name": "Paris Meetup",
  "date": "2026-03-12",
  "tags": ["online", "paris"]
}
```

## Role

- `create` adds one entity and prints the entity that was created, as `read`
would have returned it.

## Arguments

The content follows the schema of the entity, see
[Passing content](../../arguments.md#passing-content).

```text
# Fixed schema
$ confluence-page-create --title "Paris Meetup" --body-file ./about.md

# Open schema
$ airtable-record-create --table Meetups '{"title":"Paris Meetup","seats":80}'
```

## Template

### ZSH Wrapper

The `# Usage:` header must contain the list of flags it accepts, mirrored from
the JavaScript module. Keep only the lines of the mode of the entity.

`<service>/<entity>/<service>-<entity>-create`:

```zsh
# Create an entity of <service>, and print it as JSON
# Usage:
# $ <service>-<entity>-create --title "Paris Meetup"
# $ <service>-<entity>-create '{"title":"Paris Meetup"}'
# $ <service>-<entity>-create --data-file ./<entity>.json
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-create.js" "$@"
```

### JS Bin

The bin parses the args, calls the module and prints the entity as JSON.

`<service>/__lib/bin/<service>-<entity>-create.js`:

```javascript
// <service>-<entity>-create.js
import minimist from 'minimist';
import { entityCreate } from '../<entity>/<entity>Create.js';

const args = minimist(process.argv.slice(2));
// The content is the positional argument (open schema), or the named fields
const {
  _: [content],
  ...options
} = args;
const output = await entityCreate({ content, ...options });
console.log(JSON.stringify(output, null, 2));
```

### Module

The module takes the content as an options object and returns the created
entity.

`<service>/__lib/<entity>/<entity>Create.js`:

```javascript
import { callApi } from '../callApi.js';
import { formatEntity } from './format<Entity>.js';

export let __;

/**
 * Create one entity of the service
 * @param {object} options - Content of the entity
 * @returns {Promise<object>} The new entity, formatted
 */
export async function entityCreate(options) {
  // Build the content from the options (JSON, --data-file or named fields)

  // Transform the content into the body of the API call

  // Call the API: the path first, then the method and the body
  await __.callApi(path, options);

  // Return the new entity, passed through __.formatEntity
}

__ = {
  callApi,
  formatEntity,
};
```

### Test

The vitest test covers the module only. It mocks `callApi` through `__` and
mostly checks three behaviors:
- Given the content, the module calls `callApi` with the right method, path and
  body.
- Given a `-file` flag, the file content wins over the inline value.
- The returned value is the response of the API, passed through `formatEntity`.

The zsh wrapper and the bin are so thin that they need no test.
