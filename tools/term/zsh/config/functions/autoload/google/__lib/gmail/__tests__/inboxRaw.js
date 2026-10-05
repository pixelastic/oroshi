import { __, gmailInboxRaw } from '../inboxRaw.js';
import { gmailThreads } from '../threads.js';

describe('gmailInboxRaw', () => {
  const thread = (
    threadId,
    unread = false,
    lastMessageDate = 'Sat, 03 Oct 2026 21:26:59 +0200',
  ) => ({
    threadId,
    unread,
    date: '2026-10-03T19:26:59.000Z',
    count: 1,
    authors: ['Alice'],
    subject: `subject ${threadId}`,
    snippet: '',
    lastMessageId: `m-${threadId}`,
    lastMessageDate,
  });

  beforeEach(() => {
    vi.spyOn(__, 'googleAuth').mockReturnValue({ fake: 'auth' });
    vi.spyOn(gmailThreads, 'list').mockImplementation((_auth, { query }) =>
      query === 'in:inbox is:important'
        ? [thread('i1'), thread('i2')]
        : [thread('e1'), thread('e2')],
    );
  });

  it('lists the important threads, then everything else, like the Gmail inbox', async () => {
    const actual = await gmailInboxRaw('pro', 10);

    expect(actual.map((line) => line.split('▮')[0])).toEqual([
      'i1',
      'i2',
      'e1',
      'e2',
    ]);
  });

  it('asks each section for the limit that remains', async () => {
    await gmailInboxRaw('pro', 10);

    expect(gmailThreads.list).toHaveBeenNthCalledWith(
      1,
      { fake: 'auth' },
      { query: 'in:inbox is:important', limit: 10 },
    );
    expect(gmailThreads.list).toHaveBeenNthCalledWith(
      2,
      { fake: 'auth' },
      { query: 'in:inbox -is:important', limit: 8 },
    );
  });

  it('shows a thread once when it matches both sections', async () => {
    vi.spyOn(gmailThreads, 'list').mockImplementation((_auth, { query }) =>
      query === 'in:inbox is:important'
        ? [thread('i1'), thread('x')]
        : [thread('x'), thread('e1')],
    );

    const actual = await gmailInboxRaw('pro', 10);

    expect(actual.map((line) => line.split('▮')[0])).toEqual(['i1', 'x', 'e1']);
  });

  it('puts the unread threads first, among the threads of the limit', async () => {
    vi.spyOn(gmailThreads, 'list').mockImplementation((_auth, { query }) =>
      query === 'in:inbox is:important'
        ? [thread('i1'), thread('i2', true)]
        : [thread('e1', true), thread('e2')],
    );

    const actual = await gmailInboxRaw('pro', 3);

    expect(actual.map((line) => line.split('▮')[0])).toEqual([
      'i2',
      'e1',
      'i1',
    ]);
  });

  it('sorts by last message date, unread threads first', async () => {
    vi.spyOn(gmailThreads, 'list').mockImplementation((_auth, { query }) =>
      query === 'in:inbox is:important'
        ? [
            thread('i1', false, 'Mon, 05 Oct 2026 10:00:00 +0200'),
            thread('i2', true, 'Mon, 05 Oct 2026 08:00:00 +0200'),
            thread('i3', false, 'Sun, 04 Oct 2026 10:00:00 +0200'),
          ]
        : [
            thread('e1', true, 'Mon, 05 Oct 2026 09:00:00 +0200'),
            thread('e2', false, 'Mon, 05 Oct 2026 11:00:00 +0200'),
          ],
    );

    const actual = await gmailInboxRaw('pro', 10);

    expect(actual.map((line) => line.split('▮')[0])).toEqual([
      'e1',
      'i2',
      'e2',
      'i1',
      'i3',
    ]);
  });

  it('never exceeds the limit', async () => {
    const actual = await gmailInboxRaw('pro', 3);

    expect(actual).toHaveLength(3);
  });
});
