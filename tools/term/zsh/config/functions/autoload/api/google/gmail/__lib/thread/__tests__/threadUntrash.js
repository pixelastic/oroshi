import { firostError } from 'firost';
import { __, threadUntrash } from '../threadUntrash.js';

describe('threadUntrash', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callThread').mockReturnValue({ id: 't1', messages: [] });
  });

  it('restores the Thread from the trash, with the dedicated endpoint', async () => {
    await threadUntrash({ threadId: 't1' });

    expect(__.callThread).toHaveBeenCalledWith({
      threadId: 't1',
      action: 'untrash',
    });
  });

  it('returns the threadId', async () => {
    const actual = await threadUntrash({ threadId: 't1' });

    expect(actual).toEqual({ threadId: 't1' });
  });

  it('fails with GMAIL_THREAD_ID_MISSING without an id, with no API call', async () => {
    let actual = null;
    try {
      await threadUntrash({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_ID_MISSING');
    expect(__.callThread).not.toHaveBeenCalled();
  });

  it('lets the error of callThread through', async () => {
    __.callThread.mockImplementation(() => {
      throw firostError('GMAIL_THREAD_NOT_FOUND', 'Thread t1 not found');
    });

    let actual = null;
    try {
      await threadUntrash({ threadId: 't1' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
  });
});
