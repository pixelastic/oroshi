import { __, threadUpdate } from '../threadUpdate.js';

describe('threadUpdate', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 't1',
      messages: [{ id: 'm1', labelIds: ['INBOX'] }],
    });
  });

  it.each([
    {
      title: 'removes the UNREAD label when marking as read',
      options: { read: true },
      expected: { removeLabelIds: ['UNREAD'] },
    },
    {
      title: 'adds the UNREAD label when marking as unread',
      options: { unread: true },
      expected: { addLabelIds: ['UNREAD'] },
    },
  ])('$title', async ({ options, expected }) => {
    await threadUpdate({ threadId: 't1', ...options });

    expect(__.callApi).toHaveBeenCalledWith('threads/t1/modify', {
      method: 'POST',
      body: expected,
    });
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
      __.callApi.mockReturnValue(input);

      const actual = await threadUpdate({ threadId: 't1', ...options });

      expect(actual).toEqual(expected);
    },
  );
});
