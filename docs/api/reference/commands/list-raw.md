# `list-raw`

`list-raw` prints the entities of a service as plain lines, one entity per line,
with the most common fields, so that agents and scripts can parse them easily.

## Example

```text
recA▮Paris Meetup▮2026-03-12▮online▯paris
recB▮Lyon Meetup▮▮
```

## Role

- One line per entity, fields separated by `▮`.
- The values of a multi-value field are separated by `▯`.
- The **id always comes first**. The other columns depend on the entity.
- An empty field leaves an empty column: `recB▮Lyon Meetup▮▮` has two empty
  columns.
- A newline inside a value becomes a space.
- The module removes `▮` and `▯` from the values, so they cannot break the
  columns.
- An empty listing prints one empty line.

`list-raw` sits on top of [`search`](search.md): it passes its flags to
`search`, gets the JSON back and turns it into lines.

If the service has no endpoint to search the entities, `search` is skipped.
`list-raw` then calls `callApi` directly, with the most realistic call.

## Arguments

`list-raw` accepts the same flags as [`search`](search.md), and passes them
through.

## Template

### ZSH Wrapper

The `# Fields:` header is the reference documentation of the fields that
`list-raw` returns, in the same order as the columns. `helper-documentation`
prints it, so a caller knows the output format. The developer keeps it in sync
with `toLine`.

`<service>/<entity>/<service>-<entity>-list-raw`:

```zsh
# List the entities of <service>, one per line
# Fields: <entity>Id▮name▮date▮tags
# Usage:
# $ <service>-<entity>-list-raw
# $ <service>-<entity>-list-raw --limit 10
# $ <service>-<entity>-list-raw --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-list-raw.js" "$@"
```

### JS Bin

The bin is named like its wrapper, in kebab-case.
It parses the args, unpacks them into the options object of the module, calls it
and outputs the result.

`<service>/__lib/bin/<service>-<entity>-list-raw.js`:

```javascript
// <service>-<entity>-list-raw.js
import minimist from 'minimist';
import { entityListRaw } from '../<entity>/<entity>ListRaw.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The query is the first positional argument, the filters are named
const {
  _: [query],
  account,
  ...filters
} = args;
setAccount(account);
const output = await entityListRaw({ query, ...filters });
console.log(output);
```

### Module

The core of the logic. The module takes an options object and returns the lines
as one multi-line string.

`<service>/__lib/<entity>/<entity>ListRaw.js`:

#### On top of `search`

```javascript
import { _ } from 'golgoth';
import { entitySearch } from './<entity>Search.js';

export let __;

/**
 * List the entities as raw lines, one per entity
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function entityListRaw(options) {
  // Ask search for the entities, with the flags we received
  const entities = await __.entitySearch(options);

  // One line per entity
  return _.chain(entities).map(__.toLine).join('\n').value();
}

__ = {
  /**
   * Turn one entity into a raw line
   * @param {object} entity - Entity as returned by search
   * @returns {string} The fields, separated by ▮
   */
  toLine(entity) {
    // Pick the fields of the entity to show, then apply the raw format rules
    // of the Role section: join multi-values with ▯, replace newlines with a
    // space and remove the separators from the values
    const fields = [entity.id];
    return fields.join('▮');
  },
  entitySearch,
};
```

#### Direct

```javascript
import { _ } from 'golgoth';
import { callApi } from '../callApi.js';

export let __;

/**
 * List the entities as raw lines, one per entity
 * @param {object} options - The flags accepted by the command
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function entityListRaw(options) {
  // Transform options into the query of the API call
  const query = {};

  // Call the endpoint that returns the entities, paginating up to --limit
  // (page or cursor, each module paginates itself)
  const entities = await __.callApi('entities', { query });

  // One line per entity
  return _.chain(entities).map(__.toLine).join('\n').value();
}

__ = {
  /**
   * Turn one entity of the API response into a raw line
   * @param {object} entity - Entity as returned by the API
   * @returns {string} The fields, separated by ▮
   */
  toLine(entity) {
    // Pick the fields of the entity to show, then apply the raw format rules
    // of the Role section
  },
  callApi,
};
```

### Test

The test lives in `<service>/__lib/<entity>/__tests__/<entity>ListRaw.js`.

The vitest test covers the module only. The zsh wrapper and bin are so thin we
don't need to test them.

The `toLine` test gives `toLine` a minimal inline entity and asserts the line it
builds.
