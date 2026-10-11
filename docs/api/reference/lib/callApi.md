# `callApi`

`callApi` sends one request to the service and returns what the service
answers.

## Role

- `callApi` is the only way to talk to the service.
- It is the only module that talks to the network.
- It exposes the HTTP call as `__.fetch`, so tests mock it.
- Other modules call it through `__` (`__.callApi()`), so their tests mock it.
- It throws a `firostError` on every failure
  ([architecture.md](../../architecture.md#errors)).
- Each service owns one, in `<service>/__lib/callApi.js`.

## Inputs/Outputs

- Input: `callApi(path, options)`. The `path` of the endpoint comes first. The
  `options` object is optional, and holds these keys:
  - `method`: the HTTP method. The default is `GET`.
  - `body`: the body of the request. The default is no body.
  - `query`: the query parameters of the URL.
  - `headers`: the headers of the request.
- `method` and `body` override their default.
- `query` and `headers` merge over the defaults of the service. A passed key
  replaces the default key. An `Authorization` header can be replaced this way.
- `callApi` builds the URL from the path and the query.
- Output: the parsed JSON response of the API.
- An empty response body is returned as it is. A successful delete does not
  throw.
- Error: a `firostError` coded `<SERVICE>_REQUEST_FAILED`, for every failure:
  no network, a non-2xx status, or a 2xx body that is not JSON. The message
  tells them apart: the message of the original error, or the body of the API.

## Template

`<service>/__lib/callApi.js`:

```javascript
import { firostError } from 'firost';
import { getConfig } from './getConfig.js';

export let __;

/**
 * Call the API of the service
 * @param {string} path - Path of the endpoint
 * @param {object} [options] - Request options
 * @param {string} [options.method] - HTTP method
 * @param {object} [options.body] - Body of the request
 * @param {object} [options.query] - Query parameters, merged over the defaults
 * @param {object} [options.headers] - Headers, merged over the defaults
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  const { method = 'GET', body, query, headers } = options;

  // 1. Read the config of the service
  const { token } = await __.getConfig();

  // 2. Build the URL from the path and the query. The base URL is fixed, or
  //    comes from the config. The query is the default query of the service,
  //    with `query` merged over it: a passed key replaces a default key
  const defaultQuery = {};
  const search = new URLSearchParams({ ...defaultQuery, ...query });
  const url = `https://api.<service>.com/${path}?${search}`;

  // 3. Build the headers the same way: the default headers of the service,
  //    with `headers` merged over them. The defaults hold the authentication.
  //    Adapt to the service:
  //    - a token in the Authorization header
  //    - a key in a custom header
  const defaultHeaders = { Authorization: `Bearer ${token}` };

  // 4. Call the API. `method` and `body` replace the defaults.
  //    Encode the body the way the service expects (for instance JSON)
  let response;
  try {
    response = await __.fetch(url, {
      method,
      headers: { ...defaultHeaders, ...headers },
      body: body && JSON.stringify(body),
    });
  } catch (error) {
    throw firostError('<SERVICE>_REQUEST_FAILED', error.message);
  }

  // 5. Read the body as text, so that an empty body does not throw
  const text = await response.text();

  // 6. Check the status before parsing. A failure becomes a firostError
  //    (see architecture.md#errors)
  if (!response.ok) {
    throw firostError('<SERVICE>_REQUEST_FAILED', text);
  }

  // 7. Return an empty body as it is, parse anything else
  if (!text) {
    return text;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw firostError('<SERVICE>_REQUEST_FAILED', text);
  }
}

__ = { fetch, getConfig };
```

The test covers the function only. It mocks `__.getConfig` and `__.fetch`, and
checks these behaviors:
- Given a successful response, the function returns its JSON body.
- Given an empty body, the function returns it without throwing.
- Given `query` and `headers`, the request holds them merged over the defaults.
- Given a `fetch` that throws, the function throws `<SERVICE>_REQUEST_FAILED`,
  with the message of the original error.
- Given a 2xx body that is not JSON, the function throws
  `<SERVICE>_REQUEST_FAILED`, with the body as message.
- Given a failed response, the function throws `<SERVICE>_REQUEST_FAILED`, with
  the body of the API as message.
