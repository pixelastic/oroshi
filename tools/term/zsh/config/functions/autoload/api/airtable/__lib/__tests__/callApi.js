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
      response(200, JSON.stringify({ id: 'recA' })),
    );
  });

  it('returns the parsed JSON body', async () => {
    const actual = await callApi('appA/tblA');

    expect(actual).toEqual({ id: 'recA' });
  });

  it('returns an empty body as it is', async () => {
    __.fetch.mockReturnValue(response(200, ''));

    const actual = await callApi('appA/tblA/recA', { method: 'DELETE' });

    expect(actual).toEqual('');
  });

  it('sends the Bearer token, the method, the query and the body', async () => {
    await callApi('appA/tblA', {
      method: 'POST',
      query: { pageSize: 10 },
      body: { fields: { Name: 'A' } },
    });

    const [url, request] = __.fetch.mock.calls[0];
    expect(url).toEqual('https://api.airtable.com/v0/appA/tblA?pageSize=10');
    expect(request).toHaveProperty('method', 'POST');
    expect(request).toHaveProperty(
      'headers.Authorization',
      'Bearer secret-token',
    );
    expect(request).toHaveProperty(
      'body',
      JSON.stringify({ fields: { Name: 'A' } }),
    );
  });

  it('lets the headers replace the default ones', async () => {
    await callApi('appA/tblA', { headers: { Authorization: 'Other' } });

    const actual = __.fetch.mock.calls[0][1].headers.Authorization;
    expect(actual).toEqual('Other');
  });

  it('uses the base URL it is given instead of the default one', async () => {
    await callApi('appA/recA/fldA/upload', {
      baseUrl: 'https://content.airtable.com/v0',
      method: 'POST',
    });

    const actual = __.fetch.mock.calls[0][0];
    expect(actual).toEqual(
      'https://content.airtable.com/v0/appA/recA/fldA/upload',
    );
  });

  it.each([
    {
      title: 'a non-2xx response',
      setup: () => response(404, '{"error":{"message":"NOT_FOUND"}}'),
      expected: '404 {"error":{"message":"NOT_FOUND"}}',
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
      await callApi('appA/tblA');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', expected);
  });

  it('throws when fetch itself throws', async () => {
    __.fetch.mockImplementation(() => {
      throw new Error('getaddrinfo ENOTFOUND');
    });

    let actual = null;
    try {
      await callApi('appA/tblA');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'getaddrinfo ENOTFOUND');
  });
});
