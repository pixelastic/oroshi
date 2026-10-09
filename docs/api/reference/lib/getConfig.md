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

- Input: none.
- Output: an object with the configuration of the service. Its keys depend on
  the service (`token`, `baseUrl`, …).
- A service with several accounts reads the one it is asked for
  ([architecture.md](../../architecture.md#accounts)).

## Template

`<service>/__lib/getConfig.js`:

```javascript
/**
 * Read the configuration of the service from the environment
 * @returns {object} The credentials and the configuration of the service
 */
export function getConfig() {
  // One key per variable, each prefixed with the name of the service.
  // Add the keys your service needs (base URL, account, etc.)
  return {
    token: process.env.<SERVICE>_TOKEN,
  };
}
```

The test covers the function only. It sets the environment variables and checks
the returned object.
