import { gmailFormatRaw } from '../formatRaw.js';
import { gmailParseRaw } from '../parseRaw.js';
import { __ as separators } from '../separators.js';

describe('gmailParseRaw', () => {
  beforeEach(() => {
    vi.spyOn(separators, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
  });

  it.each([
    {
      title: 'gives back the fields of a formatted line',
      thread: {
        threadId: 't1',
        unread: true,
        date: 'Fri, 03 Oct 2026 21:26:59 +0200',
        count: 3,
        authors: ['Bob', 'Alice Martin'],
        subject: 'Quarterly report',
        snippet: 'Please find the report attached',
      },
      expected: {
        threadId: 't1',
        unread: true,
        date: '2026-10-03T19:26:59.000Z',
        count: 3,
        authors: ['Bob', 'Alice Martin'],
        subject: 'Quarterly report',
        snippet: 'Please find the report attached',
      },
    },
    {
      title: 'gives back a read thread without authors',
      thread: {
        threadId: 't2',
        unread: false,
        date: '',
        count: 1,
        authors: [],
        subject: '',
        snippet: '',
      },
      expected: {
        threadId: 't2',
        unread: false,
        date: '',
        count: 1,
        authors: [],
        subject: '',
        snippet: '',
      },
    },
  ])('$title', async ({ thread, expected }) => {
    const actual = await gmailParseRaw(await gmailFormatRaw(thread));

    expect(actual).toEqual(expected);
  });
});
