# `getConfig`

`getConfig` reads the credentials and other configuration of a service.

## Role

- `getConfig` is the only way to read the credentials and the configuration of
  the service.
- Other modules call it through `__` (`__.getConfig()`), so tests mock it and
  never touch the environment.
- Env variables are prefixed with the name of the service: `<SERVICE>_TOKEN`,
  `<SERVICE>_BASE_URL`.
- Each service owns one, in `<service>/__lib/getConfig.js`.

## Inputs/Outputs

- Input: none. A service with several accounts takes the `account` to read
  ([architecture.md](../../architecture.md#accounts)).
- Output: an object with the configuration of the service. Its keys depend on
  the service (`token`, `baseUrl`, …).
- Error: `<SERVICE>_TOKEN_MISSING` when a required variable is empty.
- An OAuth API reads its app id and secret here. Its tokens come from
  [`login`](../commands/login.md), not from `getConfig`.

## Template

`<service>/__lib/getConfig.js`:

```javascript
import { firostError } from 'firost';

/**
 * Read the configuration of the service from the environment
 * @returns {object} The credentials and the configuration of the service
 */
export function getConfig() {
  // One key per variable, each prefixed with the name of the service.
  // Add the keys your service needs (base URL, account, etc.)
  const token = process.env.<SERVICE>_TOKEN;

  // Fail early when a required variable is empty
  if (!token) {
    throw firostError('<SERVICE>_TOKEN_MISSING', 'Set <SERVICE>_TOKEN');
  }

  return { token };
}
```

The test covers the function only. It sets the environment variables and checks
the returned object. It also checks that an empty variable throws the typed
error.
