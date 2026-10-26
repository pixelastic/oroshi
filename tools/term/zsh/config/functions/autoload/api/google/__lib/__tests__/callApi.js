import { __, callApi } from '../callApi.js';

describe('callApi', () => {
  const BASE_URL = 'https://docs.googleapis.com/v1';
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });
  const staleTokens = { access_token: 'stale', refresh_token: 'r/1' };
  const freshTokens = {
    access_token: 'fresh',
    refresh_token: 'r/1',
    expires_at: 10_000_000,
  };

  beforeEach(() => {
    vi.spyOn(Date, 'now').mockReturnValue(1_000_000);
    vi.spyOn(__, 'getConfig').mockReturnValue({ tokens: staleTokens });
    vi.spyOn(__, 'refreshTokens').mockReturnValue(freshTokens);
    vi.spyOn(__, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ documentId: 'docA' })),
    );
  });

  it('returns the parsed JSON body, sent with the refreshed tokens', async () => {
    const actual = await callApi('documents/docA', { baseUrl: BASE_URL });

    expect(actual).toEqual({ documentId: 'docA' });
    const [url, request] = __.fetch.mock.calls[0];
    expect(url).toEqual(`${BASE_URL}/documents/docA`);
    expect(request).toHaveProperty('method', 'GET');
    expect(request).toHaveProperty('headers.Authorization', 'Bearer fresh');
  });

  describe('token refresh', () => {
    it('refreshes the tokens that have no expiry date', async () => {
      await callApi('documents/docA', { baseUrl: BASE_URL });

      expect(__.refreshTokens).toHaveBeenCalledWith(staleTokens);
    });

    it('refreshes the tokens that are about to expire', async () => {
      __.getConfig.mockReturnValue({
        tokens: { ...staleTokens, expires_at: 1_030_000 },
      });

      await callApi('documents/docA', { baseUrl: BASE_URL });

      expect(__.refreshTokens).toHaveBeenCalled();
    });

    it('keeps the tokens that are still valid', async () => {
      __.getConfig.mockReturnValue({ tokens: freshTokens });

      await callApi('documents/docA', { baseUrl: BASE_URL });

      expect(__.refreshTokens).not.toHaveBeenCalled();
      const actual = __.fetch.mock.calls[0][1].headers.Authorization;
      expect(actual).toEqual('Bearer fresh');
    });

    it('goes on with the current tokens when the refresh fails', async () => {
      __.refreshTokens.mockImplementation(() => {
        throw new Error('invalid_grant');
      });

      await callApi('documents/docA', { baseUrl: BASE_URL });

      const actual = __.fetch.mock.calls[0][1].headers.Authorization;
      expect(actual).toEqual('Bearer stale');
    });
  });

  describe('errors', () => {
    const call = async (options) => {
      let actual = null;
      try {
        await callApi('documents/docA', { baseUrl: BASE_URL, ...options });
      } catch (error) {
        actual = error;
      }
      return actual;
    };

    it('asks for a login on a 401', async () => {
      __.fetch.mockReturnValue(response(401, '{"error":"UNAUTHENTICATED"}'));

      const actual = await call();

      expect(actual).toHaveProperty('code', 'GOOGLE_LOGIN_REQUIRED');
      expect(actual).toHaveProperty('message', 'run google-login');
    });

    it.each([
      {
        title: 'a non-2xx response',
        setup: () => response(404, '{"error":"NOT_FOUND"}'),
        expected: '404 {"error":"NOT_FOUND"}',
      },
      {
        title: 'a 2xx body that is not JSON',
        setup: () => response(200, '<html>'),
        expected: '<html>',
      },
    ])(
      'throws the request error passed by the caller on $title',
      async ({ setup, expected }) => {
        __.fetch.mockReturnValue(setup());

        const actual = await call({ errorCode: 'GDOC_REQUEST_FAILED' });

        expect(actual).toHaveProperty('code', 'GDOC_REQUEST_FAILED');
        expect(actual).toHaveProperty('message', expected);
      },
    );

    it('throws the default request error when fetch itself throws', async () => {
      __.fetch.mockImplementation(() => {
        throw new Error('getaddrinfo ENOTFOUND');
      });

      const actual = await call();

      expect(actual).toHaveProperty('code', 'GOOGLE_REQUEST_FAILED');
      expect(actual).toHaveProperty('message', 'getaddrinfo ENOTFOUND');
    });
  });

  it('returns an empty body as it is', async () => {
    __.fetch.mockReturnValue(response(200, ''));

    const actual = await callApi('files/fileA', {
      baseUrl: BASE_URL,
      method: 'DELETE',
    });

    expect(actual).toEqual('');
  });

  describe('body', () => {
    it('sends a plain object as JSON', async () => {
      await callApi('documents', {
        baseUrl: BASE_URL,
        method: 'POST',
        body: { title: 'A' },
      });

      const request = __.fetch.mock.calls[0][1];
      expect(request).toHaveProperty('body', JSON.stringify({ title: 'A' }));
      expect(request).toHaveProperty(
        'headers.Content-Type',
        'application/json',
      );
    });

    it.each([
      { title: 'a FormData', body: new FormData() },
      { title: 'a Buffer', body: Buffer.from('raw') },
      { title: 'a string', body: 'raw' },
    ])('sends $title untouched', async ({ body }) => {
      await callApi('upload', {
        baseUrl: BASE_URL,
        method: 'POST',
        body,
        headers: { 'Content-Type': 'text/plain' },
      });

      const request = __.fetch.mock.calls[0][1];
      expect(request).toHaveProperty('body', body);
      expect(request).toHaveProperty('headers.Content-Type', 'text/plain');
    });
  });

  it('merges the query and the headers over the defaults', async () => {
    await callApi('files', {
      baseUrl: BASE_URL,
      query: { fields: 'id,name' },
      headers: { Authorization: 'Other' },
    });

    const [url, request] = __.fetch.mock.calls[0];
    expect(url).toEqual(`${BASE_URL}/files?fields=id%2Cname`);
    expect(request).toHaveProperty('headers.Authorization', 'Other');
  });
});
