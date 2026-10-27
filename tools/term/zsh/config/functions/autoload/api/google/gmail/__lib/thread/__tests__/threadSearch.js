import { __, threadSearch } from '../threadSearch.js';

describe('threadSearch', () => {
  /**
   * Build a Gmail Thread, as returned with the metadata format
   * @param {string} id - Thread id
   * @param {object} fields - Fields of the Thread
   * @returns {object} Gmail thread resource
   */
  function thread(id, fields = {}) {
    const { authors = ['Alice'] } = fields;
    return {
      id,
      messages: authors.map((author, index) => ({
        id: `${id}-${index}`,
        internalDate: String(index + 1),
        labelIds: ['INBOX'],
        snippet: `Snippet ${id}`,
        payload: {
          headers: [
            { name: 'From', value: `${author} <${author}@example.com>` },
            { name: 'Subject', value: `Subject ${id}` },
            { name: 'Date', value: 'Fri, 03 Oct 2026 21:26:59 +0200' },
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

  beforeEach(() => {
    mockThreads([thread('c1'), thread('c2'), thread('c3')]);
  });

  it('sends the query as q', async () => {
    await threadSearch({ query: 'from:bob is:unread' });

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { q: 'from:bob is:unread', maxResults: 25 },
    });
  });

  it('returns one envelope per Thread, with its threadId', async () => {
    const actual = await threadSearch({ query: 'from:bob' });

    expect(actual).toEqual(
      ['c1', 'c2', 'c3'].map((id) => ({
        threadId: id,
        subject: `Subject ${id}`,
        unread: false,
        messages: [
          {
            messageId: `${id}-0`,
            from: 'Alice <Alice@example.com>',
            subject: `Subject ${id}`,
            date: 'Fri, 03 Oct 2026 21:26:59 +0200',
            snippet: `Snippet ${id}`,
          },
        ],
      })),
    );
  });

  it('returns the metadata of every Message of a Thread', async () => {
    mockThreads([thread('c1', { authors: ['Alice', 'Bob'] })]);

    const actual = await threadSearch({ query: 'from:bob' });

    expect(actual[0].messages.map((item) => item.messageId)).toEqual([
      'c1-0',
      'c1-1',
    ]);
    expect(actual[0].messages.map((item) => item.from)).toEqual([
      'Alice <Alice@example.com>',
      'Bob <Bob@example.com>',
    ]);
  });

  it.each(['to', 'body', 'attachments'])(
    'omits %s from each Message',
    async (key) => {
      mockThreads([thread('c1', { authors: ['Alice', 'Bob'] })]);

      const actual = await threadSearch({ query: 'from:bob' });

      actual[0].messages.forEach((item) => {
        expect(item).not.toHaveProperty(key);
      });
    },
  );

  it.each(['count', 'date', 'authors', 'snippet'])(
    'does not return %s on the Thread',
    async (key) => {
      const actual = await threadSearch({ query: 'from:bob' });

      expect(actual[0]).not.toHaveProperty(key);
    },
  );

  it('makes one API call per Thread, in the metadata format', async () => {
    await threadSearch({ query: 'from:bob' });

    const paths = __.callApi.mock.calls.map(([path]) => path);
    expect(paths).toHaveLength(4);
    paths.slice(1).forEach((path, index) => {
      expect(path).toMatch(`threads/c${index + 1}?format=metadata`);
    });
  });

  it('returns an empty list when nothing matches', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({});

    const actual = await threadSearch({ query: 'from:nobody' });

    expect(actual).toEqual([]);
  });

  it('asks for at most --limit Threads', async () => {
    mockThreads([thread('c1'), thread('c2')]);

    const actual = await threadSearch({ query: 'from:bob', limit: 2 });

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { q: 'from:bob', maxResults: 2 },
    });
    expect(actual).toHaveLength(2);
  });

  it('fails when the query is missing', async () => {
    let actual = null;
    try {
      await threadSearch({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_QUERY_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
