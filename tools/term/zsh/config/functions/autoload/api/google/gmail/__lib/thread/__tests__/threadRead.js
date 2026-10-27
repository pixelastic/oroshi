import { firostError } from 'firost';
import { __, threadRead } from '../threadRead.js';

describe('threadRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getThread').mockReturnValue({
      id: 't1',
      messages: [
        { id: 'm1', labelIds: ['INBOX'] },
        { id: 'm2', labelIds: ['INBOX'] },
      ],
    });
    vi.spyOn(__, 'getDraftIds').mockReturnValue({});
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
      messages: [
        { messageId: 'm1', isDraft: false },
        { messageId: 'm2', isDraft: false },
      ],
    });
  });

  describe('Drafts', () => {
    /**
     * Make the Thread hold Messages with the given labels
     * @param {string[][]} labels - Labels of each Message, m1 first
     */
    function threadWithLabels(labels) {
      vi.spyOn(__, 'getThread').mockReturnValue({
        id: 't1',
        messages: labels.map((labelIds, index) => ({
          id: `m${index + 1}`,
          labelIds,
        })),
      });
    }

    it('does not list the Drafts when no Message is a Draft', async () => {
      await threadRead({ threadId: 't1' });

      expect(__.getDraftIds).not.toHaveBeenCalled();
    });

    it('lists the Drafts once when a Message is a Draft', async () => {
      threadWithLabels([['INBOX'], ['DRAFT']]);
      vi.spyOn(__, 'getDraftIds').mockReturnValue({ m2: 'd2' });

      await threadRead({ threadId: 't1' });

      expect(__.getDraftIds).toHaveBeenCalledTimes(1);
    });

    it.each([
      {
        title: 'marks the Draft Message with isDraft and its draftId',
        labels: [['INBOX'], ['DRAFT']],
        draftIds: { m2: 'd2', m9: 'd9' },
        expected: [
          { messageId: 'm1', isDraft: false },
          { messageId: 'm2', isDraft: true, draftId: 'd2' },
        ],
      },
      {
        title: 'gives a different draftId to each Draft of the Thread',
        labels: [['DRAFT'], ['DRAFT']],
        draftIds: { m1: 'd1', m2: 'd2' },
        expected: [
          { messageId: 'm1', isDraft: true, draftId: 'd1' },
          { messageId: 'm2', isDraft: true, draftId: 'd2' },
        ],
      },
    ])('$title', async ({ labels, draftIds, expected }) => {
      threadWithLabels(labels);
      vi.spyOn(__, 'getDraftIds').mockReturnValue(draftIds);

      const actual = await threadRead({ threadId: 't1' });

      expect(actual).toHaveProperty('messages', expected);
    });

    it('lets the errors of the Drafts list through', async () => {
      threadWithLabels([['DRAFT']]);
      vi.spyOn(__, 'getDraftIds').mockImplementation(() => {
        throw firostError('GMAIL_REQUEST_FAILED', '500 Backend error');
      });

      let actual = null;
      try {
        await threadRead({ threadId: 't1' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
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
