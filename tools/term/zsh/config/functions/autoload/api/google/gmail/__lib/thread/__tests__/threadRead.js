import { firostError } from 'firost';
import { __, threadRead } from '../threadRead.js';

describe('threadRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getThread').mockReturnValue({ id: 't1', messages: [] });
    vi.spyOn(__, 'formatThread').mockReturnValue({
      threadId: 't1',
      subject: 'Hello',
      unread: true,
      messages: [{ messageId: 'm1' }, { messageId: 'm2' }],
      date: '2026-10-03T19:26:59.000Z',
      count: 2,
      authors: ['Alice'],
      snippet: 'Hi',
    });
  });

  it('asks for the full format of the Thread', async () => {
    await threadRead({ threadId: 't1' });

    expect(__.getThread).toHaveBeenCalledWith('t1', {
      query: { format: 'full' },
    });
  });

  it('returns the envelope of the Thread, without the list fields', async () => {
    const actual = await threadRead({ threadId: 't1' });

    expect(actual).toEqual({
      threadId: 't1',
      subject: 'Hello',
      unread: true,
      messages: [{ messageId: 'm1' }, { messageId: 'm2' }],
    });
  });

  it('fails when the id is missing', async () => {
    let actual = null;
    try {
      await threadRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_ID_MISSING');
    expect(__.getThread).not.toHaveBeenCalled();
  });

  it('fails when the Thread is not found', async () => {
    vi.spyOn(__, 'getThread').mockImplementation(() => {
      throw firostError('GMAIL_THREAD_NOT_FOUND', 'Thread unknown not found');
    });

    let actual = null;
    try {
      await threadRead({ threadId: 'unknown' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
    expect(actual).toHaveProperty('message', 'Thread unknown not found');
  });
});
