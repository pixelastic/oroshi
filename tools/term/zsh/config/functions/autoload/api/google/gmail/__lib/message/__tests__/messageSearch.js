import { __, messageSearch } from '../messageSearch.js';

describe('messageSearch', () => {
  /**
   * Build a Gmail Message, as returned with the metadata format
   * @param {string} id - Message id
   * @param {object} fields - Fields of the Message
   * @returns {object} Gmail thread resource
   */
  function message(id, fields = {}) {
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

  beforeEach(() => {
    mockMessages([message('c1'), message('c2'), message('c3')]);
  });

  it('sends the query as q', async () => {
    await messageSearch({ query: 'from:bob is:unread' });

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { q: 'from:bob is:unread', maxResults: 25 },
    });
  });

  it('returns one formatted item per Message, with its id', async () => {
    const actual = await messageSearch({ query: 'from:bob' });

    expect(actual).toEqual(
      ['c1', 'c2', 'c3'].map((id) => ({
        id,
        date: '2026-10-03T19:26:59.000Z',
        count: 1,
        authors: ['Alice'],
        subject: `Subject ${id}`,
        snippet: `Snippet ${id}`,
        unread: false,
      })),
    );
  });

  it('returns the number of mails and the authors of a Message', async () => {
    mockMessages([message('c1', { authors: ['Alice', 'Bob'] })]);

    const actual = await messageSearch({ query: 'from:bob' });

    expect(actual[0]).toHaveProperty('count', 2);
    expect(actual[0]).toHaveProperty('authors', ['Alice', 'Bob']);
  });

  it('returns an empty list when nothing matches', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({});

    const actual = await messageSearch({ query: 'from:nobody' });

    expect(actual).toEqual([]);
  });

  it('asks for at most --limit Messages', async () => {
    mockMessages([message('c1'), message('c2')]);

    const actual = await messageSearch({ query: 'from:bob', limit: 2 });

    expect(__.callApi).toHaveBeenCalledWith('threads', {
      query: { q: 'from:bob', maxResults: 2 },
    });
    expect(actual).toHaveLength(2);
  });

  it('fails when the query is missing', async () => {
    let actual = null;
    try {
      await messageSearch({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_QUERY_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
