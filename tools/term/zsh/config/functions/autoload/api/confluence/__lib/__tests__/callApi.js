import { __, callApi } from '../callApi.js';

describe('callApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      email: 'me@work.com',
      token: 'secret-token',
      cloudId: 'cloud-123',
      domain: 'work.atlassian.net',
    });
    vi.spyOn(__, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ id: '123' })),
    );
  });

  it('returns the parsed JSON body', async () => {
    const actual = await callApi('pages/123');

    expect(actual).toEqual({ id: '123' });
  });

  it('sends Basic auth to the gateway url of the cloud id', async () => {
    await callApi('pages/123', { query: { 'body-format': 'storage' } });

    const [url, request] = __.fetch.mock.calls[0];
    const credentials = Buffer.from('me@work.com:secret-token').toString(
      'base64',
    );
    expect(url).toEqual(
      'https://api.atlassian.com/ex/confluence/cloud-123/wiki/api/v2/pages/123?body-format=storage',
    );
    expect(request).toHaveProperty('method', 'GET');
    expect(request).toHaveProperty(
      'headers.Authorization',
      `Basic ${credentials}`,
    );
  });

  it('uses the API path it is given instead of the default one', async () => {
    await callApi('search', { apiPath: 'wiki/rest/api' });

    const actual = __.fetch.mock.calls[0][0];
    expect(actual).toEqual(
      'https://api.atlassian.com/ex/confluence/cloud-123/wiki/rest/api/search',
    );
  });

  it.each([
    {
      title: 'a 401, with a message about the token',
      setup: () => response(401, 'Unauthorized'),
      expected:
        '401 Unauthorized, the CONFLUENCE_TOKEN token is expired or wrong',
    },
    {
      title: 'a 404, with a message about a missing or restricted page',
      setup: () => response(404, 'Not found'),
      expected: '404 Page not found or restricted',
    },
    {
      title: 'a non-2xx response',
      setup: () => response(500, '{"message":"boom"}'),
      expected: '500 {"message":"boom"}',
    },
    {
      title: 'a 2xx body that is not JSON',
      setup: () => response(200, '<html>'),
      expected: '<html>',
    },
  ])('throws on $title', async ({ setup, expected }) => {
    __.fetch.mockReturnValue(setup());

    let actual = null;
    try {
      await callApi('pages/123');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CONFLUENCE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', expected);
  });

  it('throws when fetch itself throws', async () => {
    __.fetch.mockImplementation(() => {
      throw new Error('getaddrinfo ENOTFOUND');
    });

    let actual = null;
    try {
      await callApi('pages/123');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CONFLUENCE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'getaddrinfo ENOTFOUND');
  });
});
