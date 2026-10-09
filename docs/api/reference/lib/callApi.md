# `callApi`

`callApi` sends one request to the service and returns what the service
answers.

## Role

- `callApi` is the only way to talk to the service.
- It is the only module that talks to the network.
- It exposes the HTTP call as `__.fetch`, so tests mock it.
- Other modules call it through `__` (`__.callApi()`), so their tests mock it.
- It throws a typed error on every non-2xx status
  ([architecture.md](../../architecture.md#errors)).
- Each service owns one, in `<service>/__lib/callApi.js`.

## Inputs/Outputs

- Input: an `options` object. It has at least the `path` of the endpoint, and
  may have a `method` (default `GET`) and a `body`. A service with several
  accounts also takes the `account`, and passes it to `getConfig`.
- Output: the parsed JSON response of the API.
- Error: a `<SERVICE>_...` error, with the message `HTTP <status>: <message>`.

## Template

`<service>/__lib/callApi.js`:

```javascript
import { firostError } from 'firost';
import { getConfig } from './getConfig.js';

export let __;

/**
 * Call the API of the service
 * @param {object} options - Request options
 * @param {string} options.path - Path of the endpoint
 * @param {string} [options.method] - HTTP method
 * @param {object} [options.body] - Body of the request, sent as JSON
 * @returns {Promise<object>} The JSON response of the API
 */
export async function callApi(options) {
  const { path, method = 'GET', body } = options;

  // 1. Read the config
  const { token } = __.getConfig();

  // 2. Build the URL. The base URL is fixed, or comes from the config
  const url = `https://api.<service>.com/${path}`;

  // 3. Authenticate. Adapt to the service:
  //    - a Bearer token in the Authorization header
  //    - a key in a custom header
  //    - the OAuth tokens saved by `<service>-login` (see commands/login.md)
  const headers = { Authorization: `Bearer ${token}` };

  // 4. Call the API
  const response = await __.fetch(url, {
    method,
    headers,
    body: body && JSON.stringify(body),
  });

  // 5. Check the status before reading the body.
  //    Every non-2xx status becomes a typed error
  if (!response.ok) {
    const { message } = await response.json();
    throw firostError(
      '<SERVICE>_REQUEST_FAILED',
      `HTTP ${response.status}: ${message}`,
    );
  }

  // 6. Read the body
  return await response.json();
}

__ = { fetch, getConfig };
```

The test covers the function only. It mocks `__.getConfig` and `__.fetch`, and
checks two behaviors:
- Given a 2xx response, the function returns its JSON body.
- Given a non-2xx response, the function throws the typed error, with the status
  and the message of the API.
