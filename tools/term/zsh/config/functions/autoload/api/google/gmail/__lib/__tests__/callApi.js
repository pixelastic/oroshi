import { __ as googleInternals } from '@oroshi/google/callApi.js';
import { callApi } from '../callApi.js';

describe('callApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });

  beforeEach(() => {
    vi.spyOn(googleInternals, 'getConfig').mockReturnValue({
      tokens: { access_token: 'token', expires_at: Date.now() + 3_600_000 },
    });
    vi.spyOn(googleInternals, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ threads: [] })),
    );
  });

  it('calls the Gmail API of the current user', async () => {
    const actual = await callApi('threads');

    expect(actual).toEqual({ threads: [] });
    const [url, request] = googleInternals.fetch.mock.calls[0];
    expect(url).toEqual(
      'https://gmail.googleapis.com/gmail/v1/users/me/threads',
    );
    expect(request).toHaveProperty('headers.Authorization', 'Bearer token');
  });

  it('throws GMAIL_REQUEST_FAILED on a failure', async () => {
    googleInternals.fetch.mockReturnValue(response(404, 'NOT_FOUND'));

    let actual = null;
    try {
      await callApi('threads');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', '404 NOT_FOUND');
  });
});
