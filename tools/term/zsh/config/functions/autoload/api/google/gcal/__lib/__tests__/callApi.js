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
      response(200, JSON.stringify({ items: [] })),
    );
  });

  it('calls the Google Calendar API', async () => {
    const actual = await callApi('users/me/calendarList');

    expect(actual).toEqual({ items: [] });
    const [url, request] = googleInternals.fetch.mock.calls[0];
    expect(url).toEqual(
      'https://www.googleapis.com/calendar/v3/users/me/calendarList',
    );
    expect(request).toHaveProperty('headers.Authorization', 'Bearer token');
  });

  it('throws GCAL_REQUEST_FAILED on a failure', async () => {
    googleInternals.fetch.mockReturnValue(response(404, 'NOT_FOUND'));

    let actual = null;
    try {
      await callApi('users/me/calendarList');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', '404 NOT_FOUND');
  });
});
