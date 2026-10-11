# `search`

`search` finds entities of one type and prints them as a JSON array.
It is the low-level entry point: it accepts many filters and returns the full
data of each entity.

## Example

```json
[
  {
    "id": "recA",
    "name": "Paris Meetup",
    "date": "2026-03-12",
    "tags": ["online", "paris"]
  },
  {
    "id": "recB",
    "name": "Lyon Meetup",
    "date": "2026-04-02",
    "tags": []
  }
]
```

## Role

- `search` is the lowest-level way to find information in a service.
- It returns a JSON array, one element per entity.
- Each element goes through the `format<Entity>` function of the service.
- Search is always per entity: `<service>-<entity>-search`.
- If the service only has a global search, `<service>-<entity>-search` runs it
  and filters the results on the type of the entity.
- `search` is the foundation of [`list-raw`](list-raw.md): implement it first.
  Skip it only if the service has no endpoint to search the entities.

## Arguments

If the service API accepts a custom query language (like Gmail), the only
argument is the whole search query, written in that language.

If the service API doesn't have a custom query language, or if said language is
limited, then additional options (like `--limit`, or `--min-date`) can be added
to cover all use-cases. In that case, the positional argument is usually simply the
text to look for.

```text
# Example #1: Gmail has a query language, but still needs an option to limit the
# number of results
$ gmail-mail-search "from:alice label:work after:2026/01/01 before:2026/03/31" --limit 10

# Example #2: Notion has no query language, so the positional argument is the
# text to search, and additional named arguments configure the search further
$ notion-page-search "meetup" --limit 10
```


## Template

### ZSH Wrapper

`<service>/<entity>/<service>-<entity>-search`:

```zsh
# Search the entities of <service>, and print them as JSON
# Usage:
# $ <service>-<entity>-search "paris meetup"
# $ <service>-<entity>-search "paris meetup" --limit 10
# $ <service>-<entity>-search "paris meetup" --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h:h}/__lib"
node "${libDir}/bin/<service>-<entity>-search.js" "$@"
```

### JS Bin

The bin parses the args, unpacks them into the options object of the module,
calls it and prints the result as JSON.

`<service>/__lib/bin/<service>-<entity>-search.js`:

```javascript
// <service>-<entity>-search.js
import minimist from 'minimist';
import { entitySearch } from '../<entity>/<entity>Search.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The query is the first positional argument, the filters are named
const {
  _: [query],
  account,
  ...filters
} = args;
setAccount(account);
const output = await entitySearch({ query, ...filters });
console.log(JSON.stringify(output, null, 2));
```

### Module

The module takes an options object and returns the entities as an array of data.

`<service>/__lib/<entity>/<entity>Search.js`:

```javascript
import { callApi } from '../callApi.js';
import { formatEntity } from './format<Entity>.js';

export let __;

/**
 * Search the entities of the service
 * @param {object} options - The query, the filters and the limit
 * @returns {Promise<object[]>} The entities, formatted
 */
export async function entitySearch(options) {
  // Set default options

  // Transform options into API parameters

  // Call the API: the path first, then the query
  await __.callApi(path, { query });

  // Paginate up to --limit (page or cursor, each module paginates itself)

  // Return the results, each one passed through __.formatEntity
}

__ = {
  callApi,
  formatEntity,
};
```

### Test

The test covers the module only. It mocks `callApi` through `__` and has two
parts:

- Assert that the options passed are correctly transformed into the right API call
- Assert that each entity returned by the API is correctly formatted and
returned by the function.

The zsh wrapper and the bin are so thin that they need no test.
