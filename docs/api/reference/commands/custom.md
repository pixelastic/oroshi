# Custom verbs

A custom verb is a verb that is not in the [closed vocabulary](README.md#vocabulary).
It is an extra verb, specific to a service or to one of its entities:
`activate`, `run`, `enable`.

## Example

```text
$ n8n-workflow-activate wf42
```

## Role

- A custom verb never replaces a verb of the closed vocabulary.
- It is named `<service>-<entity>-<verb>`, like any other command.
- It may exist for one entity only, and not for the others.
- The service lists its custom verbs in its own glossary.

## Arguments and output

Each verb has its own needs, so the documentation sets no strict rule. These
guidelines keep custom verbs close to the other commands, so that their input
and output work well with them:

- The id of the entity is a positional argument, as in [`read`](read.md).
- The other arguments are named, as defined in [arguments.md](../../arguments.md).
- The output is the entity as JSON, as in [`read`](read.md), when the action
  returns one. Otherwise it is the id, as in [`delete`](delete.md).
- A verb that does not fit these guidelines may break them.

## Template

A custom verb has the same three layers as the other commands: a wrapper, a bin
and a module. Their content depends on the verb.

### JS Bin

The bin parses the args with `parseBinArgs`, calls the module and prints the
result, as in [`read`](read.md#js-bin). It prints JSON when the verb returns an
entity, and the id otherwise.

`<service>/__lib/bin/<service>-<entity>-<verb>.js`:

```javascript
// <service>-<entity>-<verb>.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { entityVerb } from '../<entity>/<entity>Verb.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument, the options are named. A flag that must
// stay a string or a boolean is declared in the minimist options
const { positional, named } = parseBinArgs({
  setAccount,
  minimist: { boolean: ['wait'] },
});
const output = await entityVerb({ entityId: positional, ...named });
console.log(
  typeof output === 'string' ? output : JSON.stringify(output, null, 2),
);
```

### Test

The test lives in `<service>/__lib/<entity>/__tests__/<entity><Verb>.js`.

The vitest test covers the module only. It mocks `callApi` through `__` and
checks what is specific to the verb: the call to the API, and the returned
value.

The zsh wrapper and the bin are so thin that they need no test.
