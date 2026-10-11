# `getConfig`

`getConfig` reads the credentials and other configuration of a service.

## Role

- `getConfig` is the only way to read the credentials and the configuration of
  the service.
- Other modules call it through `__` (`await __.getConfig()`), so tests mock it and
  never touch the environment.
- Env variables are prefixed with the name of the service: `<SERVICE>_TOKEN`,
  `<SERVICE>_BASE_URL`.
- Each service owns one, in `<service>/__lib/getConfig.js`.

## Inputs/Outputs

- `getConfig` is always `async`, whether the service reads environment
  variables or a file. Callers `await` it.
- Input: none. `getConfig` holds a private `account`, `null` by default. While it
  is `null`, `getConfig` returns the credentials of the default account.
  [`setAccount`](setAccount.md) changes it, and `getConfig` then returns the
  credentials of that account
  ([architecture.md](../../architecture.md#accounts)).
- Output: a promise of an object with the configuration of the service. Its keys depend on
  the service (`token`, `baseUrl`, …).
- Error: `<SERVICE>_CREDENTIALS_MISSING` when a required variable is empty.

## Template

`<service>/__lib/getConfig.js`:

```javascript
import { firostError } from 'firost';

export let __;

/**
 * Read the configuration of the service from the environment
 * @returns {Promise<object>} The credentials and the configuration of the service
 */
export async function getConfig() {
  const { account } = __;

  // One key per variable, each prefixed with the name of the service.
  // The account selects the variable, as defined in architecture.md#accounts.
  // Add the keys your service needs (base URL, etc.)
  const suffix = account ? `_${account.toUpperCase()}` : '';
  const token = process.env[`<SERVICE>_TOKEN${suffix}`];

  // Fail early when a required variable is empty
  if (!token) {
    throw firostError('<SERVICE>_TOKEN_MISSING', 'Set <SERVICE>_TOKEN');
  }

  return { token };
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
```

The test covers the function only. It sets the environment variables and checks
the returned object, for the default account and for another one (by setting
`__.account`). It also checks that an empty variable throws the typed error.
