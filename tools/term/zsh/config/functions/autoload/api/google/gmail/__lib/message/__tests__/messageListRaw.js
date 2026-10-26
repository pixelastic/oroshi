import { __, messageListRaw } from '../messageListRaw.js';

describe('messageListRaw', () => {
  /**
   * Build a Gmail Message, as returned with the metadata format
   * @param {string} id - Message id
   * @param {object} fields - Fields of the Message
   * @returns {object} Gmail thread resource
   */
  function message(id, fields = {}) {
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
   * Make callApi answer with the given messages
   * @param {object[]} messages - Gmail thread resources
   */
  function mockMessages(messages) {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'threads') {
        return { threads: messages.map(({ id }) => ({ id })) };
      }
      const id = path.replace(/^threads\/([^?]+).*/, '$1');
      return messages.find((item) => item.id === id);
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
    mockMessages([message('c1'), message('c2'), message('c3')]);
  });

  it('prints one row per Message, with the Message id first', async () => {
    const actual = await messageListRaw({});

    expect(ids(actual)).toEqual(['c1', 'c2', 'c3']);
  });

  it('lists the inbox, 25 messages by default', async () => {
    await messageListRaw({});

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { labelIds: 'INBOX', maxResults: 25 },
    });
  });

  it('asks for the number of messages of --limit', async () => {
    mockMessages([message('c1'), message('c2')]);

    const actual = await messageListRaw({ limit: 2 });

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { labelIds: 'INBOX', maxResults: 2 },
    });
    expect(ids(actual)).toEqual(['c1', 'c2']);
  });

  it('prints the count and all the authors of a Message', async () => {
    mockMessages([message('c1', { authors: ['Alice', 'Bob', 'Alice'] })]);

    const actual = await messageListRaw({});

    expect(actual).toEqual(
      'c1▮2026-10-03T19:26:59.000Z▮3▮Alice▯Bob▮Subject c1▮Snippet c1▮false',
    );
  });

  it('prints an empty line when the inbox is empty', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({});

    const actual = await messageListRaw({});

    expect(actual).toEqual('');
  });

  it('puts the unread messages first, then the newest first', async () => {
    mockMessages([
      message('c1', { date: 'Mon, 05 Oct 2026 10:00:00 +0200' }),
      message('c2', {
        unread: true,
        date: 'Mon, 05 Oct 2026 08:00:00 +0200',
      }),
      message('c3', { date: 'Sun, 04 Oct 2026 10:00:00 +0200' }),
      message('c4', {
        unread: true,
        date: 'Mon, 05 Oct 2026 09:00:00 +0200',
      }),
      message('c5', { date: 'Mon, 05 Oct 2026 11:00:00 +0200' }),
    ]);

    const actual = await messageListRaw({});

    expect(ids(actual)).toEqual(['c4', 'c2', 'c5', 'c1', 'c3']);
  });

  it('fetches at most 10 messages at a time', async () => {
    const all = Array.from({ length: 25 }, (_value, index) =>
      message(`c${index}`),
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

    await messageListRaw({});

    expect(peak).toBeLessThanOrEqual(10);
    expect(peak).toBeGreaterThan(1);
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'a read Message',
        entry: {
          id: 'c1',
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
        title: 'an unread Message with newlines and separators',
        entry: {
          id: 'c2',
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
