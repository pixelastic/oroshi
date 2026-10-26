import { __, postToken } from '../postToken.js';

describe('postToken', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getClientCredentials').mockReturnValue({
      clientId: 'client-id',
      clientSecret: 'client-secret',
    });
  });

  describe('on a successful response', () => {
    beforeEach(() => {
      vi.spyOn(__, 'fetch').mockReturnValue({
        ok: true,
        status: 200,
        text: () => JSON.stringify({ access_token: 'ya29' }),
      });
    });

    it('returns the JSON of the response', async () => {
      const actual = await postToken({ grant_type: 'refresh_token' });

      expect(actual).toEqual({ access_token: 'ya29' });
    });

    it('posts the form-encoded params and the client to the token endpoint', async () => {
      await postToken({ grant_type: 'refresh_token', refresh_token: 'r/1' });

      const [url, request] = __.fetch.mock.calls[0];
      expect(url).toEqual('https://oauth2.googleapis.com/token');
      expect(request).toHaveProperty('method', 'POST');
      expect(request).toHaveProperty('headers', {
        'Content-Type': 'application/x-www-form-urlencoded',
      });
      expect(Object.fromEntries(new URLSearchParams(request.body))).toEqual({
        grant_type: 'refresh_token',
        refresh_token: 'r/1',
        client_id: 'client-id',
        client_secret: 'client-secret',
      });
    });
  });

  describe('on a failed response', () => {
    it('throws a firostError with the body as message', async () => {
      vi.spyOn(__, 'fetch').mockReturnValue({
        ok: false,
        status: 400,
        text: () => '{"error":"invalid_grant"}',
      });

      let actual = null;
      try {
        await postToken({ grant_type: 'refresh_token' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GOOGLE_REQUEST_FAILED');
      expect(actual).toHaveProperty('message', '{"error":"invalid_grant"}');
    });
  });
});
