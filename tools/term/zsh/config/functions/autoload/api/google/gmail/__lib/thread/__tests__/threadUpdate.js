import { __, threadUpdate } from '../threadUpdate.js';

describe('threadUpdate', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 't1',
      messages: [{ id: 'm1', labelIds: ['INBOX'] }],
    });
  });

  it('removes the UNREAD label of the Thread through the API', async () => {
    await threadUpdate({ threadId: 't1', read: true });

    expect(__.callApi).toHaveBeenCalledWith('threads/t1/modify', {
      method: 'POST',
      body: { removeLabelIds: ['UNREAD'] },
    });
  });

  it.each([
    {
      title: 'no Message is unread in the response',
      input: { id: 't1', messages: [{ id: 'm1', labelIds: ['INBOX'] }] },
      expected: { threadId: 't1', unread: false },
    },
    {
      title: 'the response has no labelIds',
      input: { id: 't1', messages: [{ id: 'm1' }] },
      expected: { threadId: 't1', unread: false },
    },
    {
      title: 'a Message of the response is still unread',
      input: {
        id: 't1',
        messages: [{ id: 'm1', labelIds: ['INBOX', 'UNREAD'] }],
      },
      expected: { threadId: 't1', unread: true },
    },
  ])('returns $expected.unread when $title', async ({ input, expected }) => {
    __.callApi.mockReturnValue(input);

    const actual = await threadUpdate({ threadId: 't1', read: true });

    expect(actual).toEqual(expected);
  });
});
