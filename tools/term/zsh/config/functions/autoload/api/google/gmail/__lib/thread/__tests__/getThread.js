import { firostError } from 'firost';
import { __, getThread } from '../getThread.js';

describe('getThread', () => {
  it('fetches the Thread with the options', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 't1' });

    const actual = await getThread('t1', { query: { format: 'full' } });

    expect(__.callApi).toHaveBeenCalledWith('threads/t1', {
      query: { format: 'full' },
    });
    expect(actual).toEqual({ id: 't1' });
  });

  it('fails with the id of the Thread on a 404', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError(
        'GMAIL_REQUEST_FAILED',
        '404 {"error":{"message":"Requested entity was not found."}}',
      );
    });

    let actual = null;
    try {
      await getThread('unknown');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
    expect(actual).toHaveProperty('message', 'Thread unknown not found');
  });

  it.each([
    {
      title: 'an API error that is not a 404',
      error: firostError('GMAIL_REQUEST_FAILED', '500 Backend error'),
      code: 'GMAIL_REQUEST_FAILED',
    },
    {
      title: 'a login error',
      error: firostError('GOOGLE_LOGIN_REQUIRED', 'google-login'),
      code: 'GOOGLE_LOGIN_REQUIRED',
    },
  ])('lets $title through', async ({ error, code }) => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw error;
    });

    let actual = null;
    try {
      await getThread('t1');
    } catch (thrown) {
      actual = thrown;
    }

    expect(actual).toHaveProperty('code', code);
  });
});
