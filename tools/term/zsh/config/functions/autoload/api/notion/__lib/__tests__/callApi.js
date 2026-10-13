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
      response(200, JSON.stringify({ id: 'pageA' })),
    );
  });

  it('returns the parsed JSON body', async () => {
    const actual = await callApi('pages/pageA');

    expect(actual).toEqual({ id: 'pageA' });
  });

  it('returns an empty body as it is', async () => {
    __.fetch.mockReturnValue(response(200, ''));

    const actual = await callApi('pages/pageA', { method: 'PATCH' });

    expect(actual).toEqual('');
  });

  it('sends the version header, the Bearer token, the method and the body', async () => {
    await callApi('pages', { method: 'POST', body: { title: 'A' } });

    const [url, request] = __.fetch.mock.calls[0];
    expect(url).toEqual('https://api.notion.com/v1/pages');
    expect(request).toHaveProperty('method', 'POST');
    expect(request).toHaveProperty('headers.Notion-Version', '2026-03-11');
    expect(request).toHaveProperty(
      'headers.Authorization',
      'Bearer secret-token',
    );
    expect(request).toHaveProperty('headers.Content-Type', 'application/json');
    expect(request).toHaveProperty('body', JSON.stringify({ title: 'A' }));
  });

  it('merges the query over the defaults', async () => {
    await callApi('search', { query: { page_size: 10 } });

    const actual = __.fetch.mock.calls[0][0];
    expect(actual).toEqual('https://api.notion.com/v1/search?page_size=10');
  });

  it('lets the headers replace the default ones', async () => {
    await callApi('pages/pageA', {
      headers: { 'Notion-Version': '2025-01-01', Authorization: 'Other' },
    });

    const actual = __.fetch.mock.calls[0][1].headers;
    expect(actual).toHaveProperty('Notion-Version', '2025-01-01');
    expect(actual).toHaveProperty('Authorization', 'Other');
  });

  it.each([
    {
      title: 'a non-2xx response',
      setup: () => response(404, '{"code":"object_not_found"}'),
      expected: '404 {"code":"object_not_found"}',
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
      await callApi('pages/pageA');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', expected);
  });

  it('throws when fetch itself throws', async () => {
    __.fetch.mockImplementation(() => {
      throw new Error('getaddrinfo ENOTFOUND');
    });

    let actual = null;
    try {
      await callApi('pages/pageA');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'getaddrinfo ENOTFOUND');
  });
});
