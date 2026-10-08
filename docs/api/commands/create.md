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

If the entity has a fixed schema, each field is a named flag. A field that can
be long also accepts its `-file` twin.

```text
$ confluence-page-create --title "Paris Meetup" --body-file ./about.md
```

If the entity has an open schema, the content is a JSON object, passed as the
positional argument or with `--data-file`.

```text
$ airtable-record-create --table Meetups '{"title":"Paris Meetup","seats":80}'
$ notion-page-create --data-file ./page.json
```

## Template

### ZSH Wrapper

The wrapper does not parse anything. It forwards `"$@"` to the JS binary.

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

### JS Binary

The bin parses the args, calls the module and prints the entity as JSON.

`<service>/__lib/bin/<service>-<entity>-create.js`:

```javascript
// <service>-<entity>-create.js
import minimist from 'minimist';
import { entityCreate } from '../<entity>/entityCreate.js';

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

  // Call the API

  // Return the new entity, passed through __.formatEntity
}

__ = {
  callApi,
  formatEntity,
};
```

### Test

The vitest test covers the module only. It stubs `callApi` through `__` and
mostly checks three things:
- Given the content, the module calls `callApi` with the right method, path and
  body.
- Given a `-file` flag, the file content wins over the inline value.
- The returned value is the response of the API, passed through `formatEntity`.

The zsh wrapper and the node binary are so thin that they need no test.
