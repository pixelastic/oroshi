import { formatSummary } from '../formatSummary.js';

describe('formatSummary', () => {
  it('gives the flat fields of a Thread, keyed by id', () => {
    const actual = formatSummary({
      id: 't1',
      messages: [
        {
          id: 'm1',
          internalDate: '1',
          labelIds: ['INBOX', 'UNREAD'],
          snippet: 'Snippet',
          payload: {
            headers: [
              { name: 'From', value: 'Alice Martin <alice@example.com>' },
              { name: 'Subject', value: 'Hello' },
              { name: 'Date', value: 'Fri, 03 Oct 2026 21:26:59 +0200' },
            ],
          },
        },
      ],
    });

    expect(actual).toEqual({
      id: 't1',
      date: '2026-10-03T19:26:59.000Z',
      count: 1,
      authors: ['Alice Martin'],
      subject: 'Hello',
      snippet: 'Snippet',
      unread: true,
    });
  });
});
