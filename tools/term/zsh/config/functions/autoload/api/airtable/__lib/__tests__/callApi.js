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

  it.each([
    {
      title: 'a list as key[]',
      query: { fields: ['name', 'date'] },
      expected: '?fields%5B%5D=name&fields%5B%5D=date',
    },
    {
      title: 'a list of objects as key[index][property]',
      query: { sort: [{ field: 'name', direction: 'desc' }] },
      expected: '?sort%5B0%5D%5Bfield%5D=name&sort%5B0%5D%5Bdirection%5D=desc',
    },
    {
      title: 'a scalar as key=value',
      query: { pageSize: 10 },
      expected: '?pageSize=10',
    },
    {
      title: 'nothing for empty values',
      query: { pageSize: undefined, fields: [], offset: null },
      expected: '',
    },
  ])('encodes $title', async ({ query, expected }) => {
    await callApi('appA/tblA', { query });

    const actual = __.fetch.mock.calls[0][0];
    expect(actual).toEqual(`https://api.airtable.com/v0/appA/tblA${expected}`);
  });

  it('uses an absolute URL as it is', async () => {
    await callApi('https://content.airtable.com/v0/appA/recA/fldA/upload', {
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
      expected: '{"error":{"message":"NOT_FOUND"}}',
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
