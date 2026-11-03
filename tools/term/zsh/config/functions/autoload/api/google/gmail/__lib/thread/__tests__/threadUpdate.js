import { firostError } from 'firost';
import { __, threadUpdate } from '../threadUpdate.js';

describe('threadUpdate', () => {
  beforeEach(() => {
    vi.spyOn(__, 'modifyLabels').mockReturnValue({
      id: 't1',
      messages: [{ id: 'm1', labelIds: ['INBOX'] }],
    });
  });

  it.each([
    {
      title: 'the threadId is missing',
      options: { read: true },
      expected: 'GMAIL_THREAD_ID_MISSING',
    },
    {
      title: 'no flag is given',
      options: { threadId: 't1' },
      expected: 'GMAIL_THREAD_UPDATE_EMPTY',
    },
    {
      title: 'both flags are given',
      options: { threadId: 't1', read: true, unread: true },
      expected: 'GMAIL_THREAD_UPDATE_CONFLICT',
    },
  ])(
    'fails with $expected when $title, with no API call',
    async ({ options, expected }) => {
      let actual = null;
      try {
        await threadUpdate(options);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', expected);
      expect(__.modifyLabels).not.toHaveBeenCalled();
    },
  );

  it('lets the error of modifyLabels through', async () => {
    __.modifyLabels.mockImplementation(() => {
      throw firostError('GMAIL_THREAD_NOT_FOUND', 'Thread t1 not found');
    });

    let actual = null;
    try {
      await threadUpdate({ threadId: 't1', read: true });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
  });

  it.each([
    {
      title: 'removes the UNREAD label when marking as read',
      options: { read: true },
      expected: { threadId: 't1', remove: ['UNREAD'] },
    },
    {
      title: 'adds the UNREAD label when marking as unread',
      options: { unread: true },
      expected: { threadId: 't1', add: ['UNREAD'] },
    },
  ])('$title', async ({ options, expected }) => {
    await threadUpdate({ threadId: 't1', ...options });

    expect(__.modifyLabels).toHaveBeenCalledWith(expected);
  });

  it.each([
    {
      title: 'no Message is unread in the response',
      options: { read: true },
      input: { id: 't1', messages: [{ id: 'm1', labelIds: ['INBOX'] }] },
      expected: { threadId: 't1', unread: false },
    },
    {
      title: 'the response has no labelIds',
      options: { read: true },
      input: { id: 't1', messages: [{ id: 'm1' }] },
      expected: { threadId: 't1', unread: false },
    },
    {
      title: 'a Message of the response is still unread',
      options: { read: true },
      input: {
        id: 't1',
        messages: [{ id: 'm1', labelIds: ['INBOX', 'UNREAD'] }],
      },
      expected: { threadId: 't1', unread: true },
    },
    {
      title: 'the Thread is marked as unread',
      options: { unread: true },
      input: {
        id: 't1',
        messages: [{ id: 'm1', labelIds: ['INBOX', 'UNREAD'] }],
      },
      expected: { threadId: 't1', unread: true },
    },
  ])(
    'returns $expected.unread when $title',
    async ({ options, input, expected }) => {
      __.modifyLabels.mockReturnValue(input);

      const actual = await threadUpdate({ threadId: 't1', ...options });

      expect(actual).toEqual(expected);
    },
  );
});
