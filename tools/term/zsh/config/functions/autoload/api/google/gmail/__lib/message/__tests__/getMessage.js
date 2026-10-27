import { firostError } from 'firost';
import { __, getMessage } from '../getMessage.js';

describe('getMessage', () => {
  it('fetches the Message with the options', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'm1' });

    const actual = await getMessage('m1', { query: { format: 'full' } });

    expect(__.callApi).toHaveBeenCalledWith('messages/m1', {
      query: { format: 'full' },
    });
    expect(actual).toEqual({ id: 'm1' });
  });

  it('fails with the id of the Message on a 404', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError(
        'GMAIL_REQUEST_FAILED',
        '404 {"error":{"message":"Requested entity was not found."}}',
      );
    });

    let actual = null;
    try {
      await getMessage('unknown');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_MESSAGE_NOT_FOUND');
    expect(actual).toHaveProperty('message', 'Message unknown not found');
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
      await getMessage('m1');
    } catch (thrown) {
      actual = thrown;
    }

    expect(actual).toHaveProperty('code', code);
  });
});
