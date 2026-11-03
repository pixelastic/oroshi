import { firostError } from 'firost';
import { __, threadUnsubscribe } from '../threadUnsubscribe.js';

describe('threadUnsubscribe', () => {
  const postHeader = {
    name: 'List-Unsubscribe-Post',
    value: 'List-Unsubscribe=One-Click',
  };

  /**
   * Build a Thread whose last Message has the given headers
   * @param {object[]} headers - Headers of the last Message
   * @returns {object} Thread, as returned by the Gmail API
   */
  function threadWith(headers) {
    return {
      id: 't1',
      messages: [
        { id: 'm1', payload: { headers: [] } },
        { id: 'm2', payload: { headers } },
      ],
    };
  }

  /**
   * Run threadUnsubscribe and return the error it throws
   * @param {object} options - Options of threadUnsubscribe
   * @returns {Promise<Error|null>} The error, or null
   */
  async function errorOf(options) {
    let actual = null;
    try {
      await threadUnsubscribe(options);
    } catch (error) {
      actual = error;
    }
    return actual;
  }

  beforeEach(() => {
    vi.spyOn(__, 'getThread').mockReturnValue(
      threadWith([
        { name: 'List-Unsubscribe', value: '<https://example.com/unsub?u=1>' },
        postHeader,
      ]),
    );
    vi.spyOn(__, 'fetch').mockReturnValue({ ok: true });
  });

  it('sends the one-click POST to the HTTPS link', async () => {
    await threadUnsubscribe({ threadId: 't1' });

    expect(__.fetch).toHaveBeenCalledWith('https://example.com/unsub?u=1', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'List-Unsubscribe=One-Click',
    });
  });

  it('returns the threadId, the url and done', async () => {
    const actual = await threadUnsubscribe({ threadId: 't1' });

    expect(actual).toEqual({
      threadId: 't1',
      url: 'https://example.com/unsub?u=1',
      done: true,
    });
  });

  it('reads the HTTPS link between angle brackets, among several links', async () => {
    __.getThread.mockReturnValue(
      threadWith([
        {
          name: 'List-Unsubscribe',
          value: '<mailto:unsub@example.com>, <https://example.com/one>',
        },
        postHeader,
      ]),
    );

    const actual = await threadUnsubscribe({ threadId: 't1' });

    expect(actual).toHaveProperty('url', 'https://example.com/one');
  });

  it('reads the headers of the last Message', async () => {
    await threadUnsubscribe({ threadId: 't1' });

    expect(__.getThread).toHaveBeenCalledWith('t1', {
      query: { format: 'metadata' },
    });
  });

  it('does not send the Google token to the link', async () => {
    await threadUnsubscribe({ threadId: 't1' });

    const [, request] = __.fetch.mock.calls[0];
    expect(request.headers).not.toHaveProperty('Authorization');
  });

  it('fails with GMAIL_UNSUBSCRIBE_NOT_AVAILABLE without List-Unsubscribe', async () => {
    __.getThread.mockReturnValue(threadWith([postHeader]));

    const actual = await errorOf({ threadId: 't1' });

    expect(actual).toHaveProperty('code', 'GMAIL_UNSUBSCRIBE_NOT_AVAILABLE');
    expect(__.fetch).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_UNSUBSCRIBE_NOT_AVAILABLE without List-Unsubscribe-Post', async () => {
    __.getThread.mockReturnValue(
      threadWith([
        { name: 'List-Unsubscribe', value: '<https://example.com/one>' },
      ]),
    );

    const actual = await errorOf({ threadId: 't1' });

    expect(actual).toHaveProperty('code', 'GMAIL_UNSUBSCRIBE_NOT_AVAILABLE');
    expect(__.fetch).not.toHaveBeenCalled();
  });

  it('fails for a mailto: only, and shows the address', async () => {
    __.getThread.mockReturnValue(
      threadWith([
        { name: 'List-Unsubscribe', value: '<mailto:unsub@example.com>' },
        postHeader,
      ]),
    );

    const actual = await errorOf({ threadId: 't1' });

    expect(actual).toHaveProperty('code', 'GMAIL_UNSUBSCRIBE_NOT_AVAILABLE');
    expect(actual).toHaveProperty(
      'message',
      'No one-click unsubscribe. Send an e-mail to unsub@example.com',
    );
    expect(__.fetch).not.toHaveBeenCalled();
  });

  it.each([
    {
      title: 'the response is not ok',
      mock: () => ({ ok: false, status: 500 }),
    },
    {
      title: 'the request throws',
      mock: () => {
        throw new Error('network down');
      },
    },
  ])(
    'fails with GMAIL_UNSUBSCRIBE_NOT_AVAILABLE when $title',
    async ({ mock }) => {
      __.fetch.mockImplementation(mock);

      const actual = await errorOf({ threadId: 't1' });

      expect(actual).toHaveProperty('code', 'GMAIL_UNSUBSCRIBE_NOT_AVAILABLE');
    },
  );

  it('fails with GMAIL_THREAD_ID_MISSING without an id, with no API call', async () => {
    const actual = await errorOf({});

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_ID_MISSING');
    expect(__.getThread).not.toHaveBeenCalled();
  });

  it('lets GMAIL_THREAD_NOT_FOUND through', async () => {
    __.getThread.mockImplementation(() => {
      throw firostError('GMAIL_THREAD_NOT_FOUND', 'Thread t1 not found');
    });

    const actual = await errorOf({ threadId: 't1' });

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
  });
});
