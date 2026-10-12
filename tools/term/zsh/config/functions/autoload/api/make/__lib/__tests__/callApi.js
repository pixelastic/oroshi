import { __, callApi } from '../callApi.js';

describe('callApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      key: 'secret-key',
      teamId: '42',
      zone: 'eu2',
    });
    vi.spyOn(__, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ scenarios: [] })),
    );
  });

  it.each([
    {
      title: 'the URL built from the zone and the path',
      options: {},
      expected: 'https://eu2.make.com/api/v2/scenarios',
    },
    {
      title: 'the base URL it is given instead of the default one',
      options: { baseUrl: 'https://other.make.com/api/v2' },
      expected: 'https://other.make.com/api/v2/scenarios',
    },
    {
      title: 'the query merged over the defaults',
      options: { query: { teamId: 42, 'pg[limit]': 10 } },
      expected: 'https://eu2.make.com/api/v2/scenarios?teamId=42&pg[limit]=10',
    },
  ])('calls $title', async ({ options, expected }) => {
    await callApi('scenarios', options);

    const actual = __.fetch.mock.calls[0][0];
    expect(actual).toEqual(expected);
  });

  it.each([
    {
      title: 'the Token authorization header',
      options: {},
      expected: 'Token secret-key',
    },
    {
      title: 'the headers merged over the defaults',
      options: { headers: { Authorization: 'Other' } },
      expected: 'Other',
    },
  ])('sends $title', async ({ options, expected }) => {
    await callApi('scenarios', options);

    const actual = __.fetch.mock.calls[0][1].headers.Authorization;
    expect(actual).toEqual(expected);
  });

  it('sends a JSON body', async () => {
    await callApi('scenarios', {
      method: 'POST',
      body: { name: 'A' },
    });

    const [, request] = __.fetch.mock.calls[0];
    expect(request).toHaveProperty('method', 'POST');
    expect(request).toHaveProperty('body', JSON.stringify({ name: 'A' }));
    expect(request).toHaveProperty('headers.Content-Type', 'application/json');
  });

  it('returns the parsed JSON body', async () => {
    const actual = await callApi('scenarios');

    expect(actual).toEqual({ scenarios: [] });
  });

  it('returns an empty body as it is', async () => {
    __.fetch.mockReturnValue(response(200, ''));

    const actual = await callApi('scenarios/1', { method: 'DELETE' });

    expect(actual).toEqual('');
  });

  it.each([
    {
      title: 'an error response',
      setup: () => response(403, '{"code":"IM002"}'),
      expected: '403 {"code":"IM002"}',
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
      await callApi('scenarios');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', expected);
  });

  it('throws when the request fails', async () => {
    __.fetch.mockImplementation(() => {
      throw new Error('getaddrinfo ENOTFOUND');
    });

    let actual = null;
    try {
      await callApi('scenarios');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'getaddrinfo ENOTFOUND');
  });
});
