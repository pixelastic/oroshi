import { formatComment } from '../formatComment.js';

describe('formatComment', () => {
  it('maps the comment, its anchor and its author', () => {
    const actual = formatComment({
      id: 'comA',
      content: 'Consider adding a diagram',
      quotedFileContent: { value: 'system overview' },
      author: { displayName: 'Bob', me: true },
      replies: [],
    });

    expect(actual).toEqual({
      id: 'comA',
      anchor: 'system overview',
      comment: 'Consider adding a diagram',
      author: { displayName: 'Bob', isMe: true },
      replies: [],
    });
  });

  it('defaults the missing anchor and author fields', () => {
    const actual = formatComment({ id: 'comA', content: 'Hello' });

    expect(actual).toEqual({
      id: 'comA',
      anchor: '',
      comment: 'Hello',
      author: { displayName: '', isMe: false },
      replies: [],
    });
  });

  it('sorts the replies by creation time and maps them', () => {
    const actual = formatComment({
      id: 'comA',
      content: 'Hello',
      replies: [
        {
          content: 'Second',
          action: 'reopen',
          createdTime: '2026-07-30T11:30:00Z',
          author: { displayName: 'Alice', me: false },
        },
        {
          content: 'First',
          createdTime: '2026-07-30T11:15:00Z',
          author: { displayName: 'Bob', me: true },
        },
      ],
    });

    expect(actual).toHaveProperty('replies', [
      { content: 'First', author: { displayName: 'Bob', isMe: true } },
      { content: 'Second', author: { displayName: 'Alice', isMe: false } },
    ]);
  });
});
