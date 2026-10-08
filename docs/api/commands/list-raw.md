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
- The **id always comes first**
- An empty field leaves an empty column: `recB▮Lyon▮▮` has two empty columns.
- A newline inside a value becomes a space.

In most cases, `list-raw` sits on top of `search`: it passes the flags it
receives to `search`, gets the JSON back and turns it into lines.

If `search` is not suitable, `list-raw` can call better-suited endpoints
instead.

## Arguments

`list-raw` accepts the same flags as `search`, and passes them through.

## Template

### ZSH Wrapper

The wrapper does not parse anything. It forwards `"$@"` to the bin.

The `# Usage:` header must contain the list of flags it accepts (mirrored from
the JavaScript module), so it is surfaced to `helper-list`.

`<service>/<entity>/<service>-<entity>-list-raw`:

```zsh
# List the entities of <service>, one per line
# Fields: <entity>Id▮name▮date
# Usage:
# $ <service>-<entity>-list-raw
# $ <service>-<entity>-list-raw --limit 10
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-list-raw.js" "$@"
```

### JS Binary

The bin is named like its wrapper, in kebab-case.
It parses the args, unpacks them into the options object of the module, calls it
and outputs the result.

`<service>/__lib/bin/<service>-<entity>-list-raw.js`:

```javascript
// <service>-<entity>-list-raw.js
import minimist from 'minimist';
import { entityListRaw } from '../<entity>/<entity>ListRaw.js';

const args = minimist(process.argv.slice(2));
// The query is the first positional argument, the filters are named
const {
  _: [query],
  ...filters
} = args;
const output = await entityListRaw({ query, ...filters });
console.log(output);
```

### Module

The core of the logic. The module takes an options object and returns the lines
as one multi-line string.

`<service>/__lib/<entity>/<entity>ListRaw.js`:

```javascript
import { _ } from 'golgoth';
import { entitySearch } from './entitySearch.js';

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
   * @returns {string} The id first, then the fields, separated by ▮
   */
  toLine(entity) {
    // Join multi-values with ▯, replace newlines with a space and remove
    // the separators from the values
    return [entity.id, entity.name, entity.date].join('▮');
  },
  entitySearch,
};
```

### Test

The test covers the module only. The zsh wrapper and bin are so thin we
don't need to test them.
