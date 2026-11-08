import { __, callApi } from '../callApi.js';

describe('callApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({ token: 'secret-token' });
    vi.spyOn(__, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ items: [] })),
    );
  });

  it.each([
    {
      title: 'the v2 URL built from the path',
      options: {},
      expected: 'https://circleci.com/api/v2/project/gh/org/repo',
    },
    {
      title: 'the base URL it is given instead of the default one',
      options: { baseUrl: 'https://circleci.com/api/v1.1' },
      expected: 'https://circleci.com/api/v1.1/project/gh/org/repo',
    },
    {
      title: 'the query merged over the defaults',
      options: { query: { branch: 'main', limit: 10 } },
      expected:
        'https://circleci.com/api/v2/project/gh/org/repo?branch=main&limit=10',
    },
  ])('calls $title', async ({ options, expected }) => {
    await callApi('project/gh/org/repo', options);

    const actual = __.fetch.mock.calls[0][0];
    expect(actual).toEqual(expected);
  });

  it.each([
    {
      title: 'the Circle-Token header',
      options: {},
      expected: 'secret-token',
    },
    {
      title: 'the headers merged over the defaults',
      options: { headers: { 'Circle-Token': 'other' } },
      expected: 'other',
    },
  ])('sends $title', async ({ options, expected }) => {
    await callApi('project/gh/org/repo', options);

    const actual = __.fetch.mock.calls[0][1].headers['Circle-Token'];
    expect(actual).toEqual(expected);
  });

  it('sends a JSON body with the method it is given', async () => {
    await callApi('workflow/abc/rerun', {
      method: 'POST',
      body: { jobs: [] },
    });

    const [, request] = __.fetch.mock.calls[0];
    expect(request).toHaveProperty('method', 'POST');
    expect(request).toHaveProperty('body', JSON.stringify({ jobs: [] }));
    expect(request).toHaveProperty('headers.Content-Type', 'application/json');
  });

  it('returns the parsed JSON body', async () => {
    const actual = await callApi('project/gh/org/repo');

    expect(actual).toEqual({ items: [] });
  });

  it('returns an empty body as it is', async () => {
    __.fetch.mockReturnValue(response(200, ''));

    const actual = await callApi('project/gh/org/repo');

    expect(actual).toEqual('');
  });

  it.each([
    {
      title: 'an error response',
      setup: () => response(404, '{"message":"Project not found"}'),
      expected: '404 {"message":"Project not found"}',
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
      await callApi('project/gh/org/repo');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', expected);
  });

  it('throws when the request fails', async () => {
    __.fetch.mockImplementation(() => {
      throw new Error('getaddrinfo ENOTFOUND');
    });

    let actual = null;
    try {
      await callApi('project/gh/org/repo');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'getaddrinfo ENOTFOUND');
  });
});
