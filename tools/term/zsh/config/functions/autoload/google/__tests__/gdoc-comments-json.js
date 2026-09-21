import { __, gdocCommentsJson } from '../__lib/gdoc-comments-json.js';

describe('extractDocId', () => {
  it.each([
    {
      title: 'full Google Docs URL',
      input: 'https://docs.google.com/document/d/abc123xyz/edit',
      expected: 'abc123xyz',
    },
    {
      title: 'URL with hash fragment',
      input: 'https://docs.google.com/document/d/abc123xyz/edit#heading=h.1',
      expected: 'abc123xyz',
    },
    {
      title: 'bare document ID',
      input: 'abc123xyz',
      expected: 'abc123xyz',
    },
  ])('$title', ({ input, expected }) => {
    const actual = __.extractDocId(input);
    expect(actual).toEqual(expected);
  });
});

describe('gdocCommentsJson', () => {
  beforeEach(() => {
    vi.spyOn(__, 'googleAuth').mockReturnValue({ credentials: 'mock' });
    // Comments returned in reverse chronological order (API default)
    vi.spyOn(__, 'fetchComments').mockReturnValue([
      {
        resolved: false,
        content: 'Comment without anchor',
        createdTime: '2026-07-30T12:00:00Z',
        author: { displayName: 'Alice', me: false },
        replies: [],
      },
      {
        resolved: false,
        content: 'Consider adding a diagram',
        quotedFileContent: { value: 'system overview' },
        createdTime: '2026-07-30T11:00:00Z',
        author: { displayName: 'Bob', me: true },
        replies: [
          {
            content: 'I agree, a diagram would help',
            action: 'reopen',
            createdTime: '2026-07-30T11:30:00Z',
            author: { displayName: 'Alice', me: false },
          },
          {
            content: 'Will add one tomorrow',
            action: 'reopen',
            createdTime: '2026-07-30T11:15:00Z',
            author: { displayName: 'Bob', me: true },
          },
        ],
      },
      {
        resolved: true,
        content: 'Fixed the typo',
        quotedFileContent: { value: 'teh' },
        createdTime: '2026-07-30T10:30:00Z',
        author: { displayName: 'Charlie', me: false },
        replies: [],
      },
      {
        resolved: false,
        content: 'Needs more detail here',
        quotedFileContent: { value: 'The architecture is simple' },
        createdTime: '2026-07-30T10:00:00Z',
        author: { displayName: 'Alice', me: false },
        replies: [
          {
            content: 'What details are missing?',
            action: 'reopen',
            createdTime: '2026-07-30T10:05:00Z',
            author: { displayName: 'Bob', me: true },
          },
        ],
      },
    ]);
  });

  it('returns only unresolved comments', async () => {
    const actual = await gdocCommentsJson('abc123');
    expect(actual).toHaveLength(3);
  });

  it.each([
    {
      title: 'maps anchor and comment fields',
      index: 0,
      expected: {
        anchor: 'The architecture is simple',
        comment: 'Needs more detail here',
        author: { displayName: 'Alice', isMe: false },
        replies: [
          {
            content: 'What details are missing?',
            author: { displayName: 'Bob', isMe: true },
          },
        ],
      },
    },
    {
      title: 'sets anchor to empty string when quotedFileContent is missing',
      index: 2,
      expected: {
        anchor: '',
        comment: 'Comment without anchor',
        author: { displayName: 'Alice', isMe: false },
        replies: [],
      },
    },
  ])('$title', async ({ index, expected }) => {
    const actual = await gdocCommentsJson('abc123');
    expect(actual).toHaveProperty(index, expected);
  });

  it('sorts comments by createdTime ascending', async () => {
    const actual = await gdocCommentsJson('abc123');
    const comments = actual.map((entry) => entry.comment);
    expect(comments).toEqual([
      'Needs more detail here',
      'Consider adding a diagram',
      'Comment without anchor',
    ]);
  });

  it('excludes resolved comments', async () => {
    const actual = await gdocCommentsJson('abc123');
    const comments = actual.map((entry) => entry.comment);
    expect(comments).not.toContain('Fixed the typo');
  });

  it('passes extracted doc ID to fetchComments', async () => {
    await gdocCommentsJson('https://docs.google.com/document/d/doc456/edit');
    expect(__.fetchComments).toHaveBeenCalledWith(expect.anything(), 'doc456');
  });

  it.each([
    {
      title: 'includes author displayName on each comment',
      mapper: (entry) => entry.author.displayName,
      expected: ['Alice', 'Bob', 'Alice'],
    },
    {
      title: 'includes author isMe boolean on each comment',
      mapper: (entry) => entry.author.isMe,
      expected: [false, true, false],
    },
  ])('$title', async ({ mapper, expected }) => {
    const actual = await gdocCommentsJson('abc123');
    const values = actual.map(mapper);
    expect(values).toEqual(expected);
  });

  it.each([
    {
      title: 'returns empty array when all comments are resolved',
      comments: [
        {
          resolved: true,
          content: 'Done',
          quotedFileContent: { value: 'old text' },
          author: { displayName: 'Alice', me: false },
        },
      ],
    },
    {
      title: 'returns empty array when there are no comments',
      comments: [],
    },
  ])('$title', async ({ comments }) => {
    vi.spyOn(__, 'fetchComments').mockReturnValue(comments);
    const actual = await gdocCommentsJson('abc123');
    expect(actual).toEqual([]);
  });

  it('includes replies array with content and author on comments that have replies', async () => {
    const actual = await gdocCommentsJson('abc123');
    expect(actual).toHaveProperty('1.replies', [
      {
        content: 'Will add one tomorrow',
        author: { displayName: 'Bob', isMe: true },
      },
      {
        content: 'I agree, a diagram would help',
        author: { displayName: 'Alice', isMe: false },
      },
    ]);
  });

  it('returns empty replies array when comment has no replies', async () => {
    const actual = await gdocCommentsJson('abc123');
    expect(actual).toHaveProperty('2.replies', []);
  });

  it('sorts replies by createdTime ascending within a comment', async () => {
    const actual = await gdocCommentsJson('abc123');
    const replyContents = actual[1].replies.map((r) => r.content);
    expect(replyContents).toEqual([
      'Will add one tomorrow',
      'I agree, a diagram would help',
    ]);
  });

  it('does not expose createdTime in reply output', async () => {
    const actual = await gdocCommentsJson('abc123');
    const repliesWithTime = actual[1].replies.filter((r) => 'createdTime' in r);
    expect(repliesWithTime).toEqual([]);
  });

  it.each([
    {
      title: 'includes displayName on each reply author',
      mapper: (r) => r.author.displayName,
      expected: ['Bob', 'Alice'],
    },
    {
      title: 'includes isMe on each reply author',
      mapper: (r) => r.author.isMe,
      expected: [true, false],
    },
  ])('$title', async ({ mapper, expected }) => {
    const actual = await gdocCommentsJson('abc123');
    const values = actual[1].replies.map(mapper);
    expect(values).toEqual(expected);
  });
});
