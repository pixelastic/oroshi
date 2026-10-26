import { __, commentListRaw } from '../commentListRaw.js';

describe('commentListRaw', () => {
  /**
   * Build a Drive comment
   * @param {string} id - Comment id
   * @param {string} createdTime - Creation time
   * @param {object} extras - Other fields of the comment
   * @returns {object} Comment, as returned by the Drive API
   */
  function comment(id, createdTime, extras = {}) {
    return {
      id,
      content: `Content ${id}`,
      createdTime,
      author: { displayName: 'Alice', me: false },
      ...extras,
    };
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      comments: [
        comment('comA', '2026-07-30T12:00:00Z'),
        comment('comB', '2026-07-30T11:00:00Z', {
          quotedFileContent: { value: 'system overview' },
          author: { displayName: 'Bob', me: true },
          replies: [
            {
              content: 'Will add one tomorrow',
              createdTime: '2026-07-30T11:15:00Z',
              author: { displayName: 'Bob', me: true },
            },
            {
              content: 'Agreed',
              createdTime: '2026-07-30T11:30:00Z',
              author: { displayName: 'Alice', me: false },
            },
          ],
        }),
        comment('comC', '2026-07-30T10:30:00Z', { resolved: true }),
      ],
    });
  });

  it('returns the unresolved comments, oldest first', async () => {
    const actual = await commentListRaw({ documentId: 'docA' });

    expect(actual).toEqual(
      [
        'comB▮system overview▮Content comB▮Bob▮true▮Bob: Will add one tomorrow▯Alice: Agreed',
        'comA▮▮Content comA▮Alice▮false▮',
      ].join('\n'),
    );
  });

  it('returns an empty string when all comments are resolved', async () => {
    __.callApi.mockReturnValue({
      comments: [comment('comC', '2026-07-30T10:30:00Z', { resolved: true })],
    });

    const actual = await commentListRaw({ documentId: 'docA' });

    expect(actual).toEqual('');
  });

  it('parses the Docs URL into the file id', async () => {
    await commentListRaw({
      documentId: 'https://docs.google.com/document/d/docA/edit',
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'files/docA/comments',
      expect.objectContaining({
        baseUrl: 'https://www.googleapis.com/drive/v3',
      }),
    );
  });

  it('throws when the document is missing', async () => {
    let actual = null;
    try {
      await commentListRaw({});
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GDOC_DOCUMENT_ID_MISSING');
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'a comment with an anchor and replies',
        entry: {
          id: 'comA',
          anchor: 'overview',
          comment: 'Add a diagram',
          author: { displayName: 'Bob', isMe: true },
          replies: [
            { content: 'Done', author: { displayName: 'Alice', isMe: false } },
            { content: 'Thanks', author: { displayName: 'Bob', isMe: true } },
          ],
        },
        expected:
          'comA▮overview▮Add a diagram▮Bob▮true▮Alice: Done▯Bob: Thanks',
      },
      {
        title: 'a comment without anchor nor replies',
        entry: {
          id: 'comB',
          anchor: '',
          comment: 'Line one\nline two',
          author: { displayName: 'Alice', isMe: false },
          replies: [],
        },
        expected: 'comB▮▮Line one line two▮Alice▮false▮',
      },
    ])('$title', ({ entry, expected }) => {
      const actual = __.toLine(entry);

      expect(actual).toEqual(expected);
    });
  });

  describe('pagination', () => {
    beforeEach(() => {
      __.callApi.mockImplementation((_path, { query }) => {
        if (query.pageToken === 'page2') {
          return {
            comments: [
              comment('comC', '2026-07-30T12:00:00Z'),
              comment('comD', '2026-07-30T13:00:00Z'),
            ],
          };
        }
        return {
          comments: [
            comment('comA', '2026-07-30T10:00:00Z'),
            comment('comB', '2026-07-30T11:00:00Z', { resolved: true }),
          ],
          nextPageToken: 'page2',
        };
      });
    });

    it('follows the pages until the limit', async () => {
      const actual = await commentListRaw({ documentId: 'docA', limit: 2 });

      expect(actual.split('\n')).toHaveLength(2);
      expect(__.callApi).toHaveBeenCalledTimes(2);
    });

    it('stops fetching when the first page reaches the limit', async () => {
      await commentListRaw({ documentId: 'docA', limit: 1 });

      expect(__.callApi).toHaveBeenCalledTimes(1);
    });

    it('returns every unresolved comment under the limit', async () => {
      const actual = await commentListRaw({ documentId: 'docA' });

      expect(actual.split('\n')).toHaveLength(3);
    });
  });
});
