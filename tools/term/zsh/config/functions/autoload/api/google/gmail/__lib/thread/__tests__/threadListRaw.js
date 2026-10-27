import { __, threadListRaw } from '../threadListRaw.js';

describe('threadListRaw', () => {
  /**
   * Build a Gmail Thread, as returned with the metadata format
   * @param {string} id - Thread id
   * @param {object} fields - Fields of the Thread
   * @returns {object} Gmail thread resource
   */
  function thread(id, fields = {}) {
    const {
      authors = ['Alice'],
      unread = false,
      date = 'Fri, 03 Oct 2026 21:26:59 +0200',
    } = fields;
    return {
      id,
      messages: authors.map((author, index) => ({
        id: `${id}-${index}`,
        internalDate: String(index + 1),
        labelIds: unread ? ['INBOX', 'UNREAD'] : ['INBOX'],
        snippet: `Snippet ${id}`,
        payload: {
          headers: [
            { name: 'From', value: `${author} <${author}@example.com>` },
            { name: 'Subject', value: `Subject ${id}` },
            { name: 'Date', value: date },
          ],
        },
      })),
    };
  }

  /**
   * Make callApi answer with the given Threads
   * @param {object[]} threads - Gmail thread resources
   */
  function mockThreads(threads) {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'threads') {
        return { threads: threads.map(({ id }) => ({ id })) };
      }
      const id = path.replace(/^threads\/([^?]+).*/, '$1');
      return threads.find((item) => item.id === id);
    });
  }

  /**
   * Read the ids of the rows
   * @param {string} output - Raw lines
   * @returns {string[]} First column of each line
   */
  function ids(output) {
    return output.split('\n').map((line) => line.split('▮')[0]);
  }

  beforeEach(() => {
    mockThreads([thread('c1'), thread('c2'), thread('c3')]);
  });

  it('prints one row per Thread, with the Thread id first', async () => {
    const actual = await threadListRaw({});

    expect(ids(actual)).toEqual(['c1', 'c2', 'c3']);
  });

  it('lists the inbox, 25 Threads by default', async () => {
    await threadListRaw({});

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { labelIds: 'INBOX', maxResults: 25 },
    });
  });

  it('asks for the number of Threads of --limit', async () => {
    mockThreads([thread('c1'), thread('c2')]);

    const actual = await threadListRaw({ limit: 2 });

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { labelIds: 'INBOX', maxResults: 2 },
    });
    expect(ids(actual)).toEqual(['c1', 'c2']);
  });

  it('prints the count and all the authors of a Thread', async () => {
    mockThreads([thread('c1', { authors: ['Alice', 'Bob', 'Alice'] })]);

    const actual = await threadListRaw({});

    expect(actual).toEqual(
      'c1▮2026-10-03T19:26:59.000Z▮3▮Alice▯Bob▮Subject c1▮Snippet c1▮false',
    );
  });

  it('prints the date of the last Message of the Thread', async () => {
    mockThreads([
      {
        id: 'c1',
        messages: [
          {
            id: 'c1-1',
            internalDate: '2',
            labelIds: ['INBOX'],
            snippet: 'Later',
            payload: {
              headers: [
                { name: 'From', value: 'Bob <bob@example.com>' },
                { name: 'Subject', value: 'Subject c1' },
                { name: 'Date', value: 'Mon, 05 Oct 2026 10:00:00 +0200' },
              ],
            },
          },
          {
            id: 'c1-0',
            internalDate: '1',
            labelIds: ['INBOX'],
            snippet: 'Earlier',
            payload: {
              headers: [
                { name: 'From', value: 'Alice <alice@example.com>' },
                { name: 'Subject', value: 'Subject c1' },
                { name: 'Date', value: 'Fri, 02 Oct 2026 10:00:00 +0200' },
              ],
            },
          },
        ],
      },
    ]);

    const actual = await threadListRaw({});

    expect(actual.split('▮')[1]).toEqual('2026-10-05T08:00:00.000Z');
  });

  it('prints the unread authors first', async () => {
    const unreadBob = thread('c1', { authors: ['Bob'], unread: true });
    const readAlice = thread('c1', { authors: ['Alice'] });
    mockThreads([
      {
        id: 'c1',
        messages: [
          { ...readAlice.messages[0], id: 'c1-0', internalDate: '1' },
          { ...unreadBob.messages[0], id: 'c1-1', internalDate: '2' },
        ],
      },
    ]);

    const actual = await threadListRaw({});

    expect(actual.split('▮')[3]).toEqual('Bob▯Alice');
  });

  it('prints an empty line when the inbox is empty', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({});

    const actual = await threadListRaw({});

    expect(actual).toEqual('');
  });

  it('puts the unread Threads first, then the newest first', async () => {
    mockThreads([
      thread('c1', { date: 'Mon, 05 Oct 2026 10:00:00 +0200' }),
      thread('c2', {
        unread: true,
        date: 'Mon, 05 Oct 2026 08:00:00 +0200',
      }),
      thread('c3', { date: 'Sun, 04 Oct 2026 10:00:00 +0200' }),
      thread('c4', {
        unread: true,
        date: 'Mon, 05 Oct 2026 09:00:00 +0200',
      }),
      thread('c5', { date: 'Mon, 05 Oct 2026 11:00:00 +0200' }),
    ]);

    const actual = await threadListRaw({});

    expect(ids(actual)).toEqual(['c4', 'c2', 'c5', 'c1', 'c3']);
  });

  it('fetches at most 10 Threads at a time', async () => {
    const all = Array.from({ length: 25 }, (_value, index) =>
      thread(`c${index}`),
    );
    let running = 0;
    let peak = 0;
    vi.spyOn(__, 'callApi').mockImplementation(async (path) => {
      if (path === 'threads') {
        return { threads: all.map(({ id }) => ({ id })) };
      }
      running++;
      peak = Math.max(peak, running);
      await new Promise((resolve) => setTimeout(resolve, 5));
      running--;
      return all.find(({ id }) => path.includes(`threads/${id}?`));
    });

    await threadListRaw({});

    expect(peak).toBeLessThanOrEqual(10);
    expect(peak).toBeGreaterThan(1);
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'a read Thread',
        entry: {
          threadId: 'c1',
          date: '2026-10-03T19:26:59.000Z',
          count: 2,
          authors: ['Bob', 'Alice Martin'],
          subject: 'Quarterly report',
          snippet: 'Please find the report',
          unread: false,
        },
        expected:
          'c1▮2026-10-03T19:26:59.000Z▮2▮Bob▯Alice Martin▮Quarterly report▮Please find the report▮false',
      },
      {
        title: 'an unread Thread with newlines and separators',
        entry: {
          threadId: 'c2',
          date: '',
          count: 1,
          authors: [],
          subject: 'Line one\nline two',
          snippet: 'a▮b▯c',
          unread: true,
        },
        expected: 'c2▮▮1▮▮Line one line two▮abc▮true',
      },
    ])('$title', ({ entry, expected }) => {
      const actual = __.toLine(entry);

      expect(actual).toEqual(expected);
    });
  });
});
