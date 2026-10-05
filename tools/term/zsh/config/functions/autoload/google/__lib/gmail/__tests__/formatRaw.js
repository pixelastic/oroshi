import { gmailFormatRaw } from '../formatRaw.js';
import { __ as separators } from '../separators.js';

describe('gmailFormatRaw', () => {
  const thread = {
    threadId: 't1',
    unread: true,
    date: 'Fri, 03 Oct 2026 21:26:59 +0200',
    count: 3,
    authors: ['Bob', 'Alice Martin'],
    subject: 'Quarterly report',
    snippet: 'Please find the report attached',
    lastMessageId: 'm9',
    lastMessageDate: 'Sat, 04 Oct 2026 10:00:00 +0200',
  };

  beforeEach(() => {
    vi.spyOn(separators, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
  });

  it('outputs nine fields in order', async () => {
    const actual = await gmailFormatRaw(thread);

    expect(actual).toEqual(
      't1▮1▮2026-10-03T19:26:59.000Z▮3▮Bob▯Alice Martin▮Quarterly report▮Please find the report attached▮m9▮2026-10-04T08:00:00.000Z',
    );
  });

  it.each([
    {
      title: 'writes a read thread as 0',
      change: { unread: false },
      field: 1,
      expected: '0',
    },
    {
      title: 'leaves the date empty when it is invalid',
      change: { date: 'not a date' },
      field: 2,
      expected: '',
    },
    {
      title: 'replaces newlines in the subject with a space',
      change: { subject: 'Hel\nlo\r\nworld' },
      field: 5,
      expected: 'Hel lo world',
    },
    {
      title: 'replaces newlines in the snippet with a space',
      change: { snippet: 'one\ntwo' },
      field: 6,
      expected: 'one two',
    },
    {
      title: 'strips both separators from the subject',
      change: { subject: 'a▮b▯c' },
      field: 5,
      expected: 'abc',
    },
    {
      title: 'strips both separators from an author name',
      change: { authors: ['Al▮ice', 'B▯ob'] },
      field: 4,
      expected: 'Alice▯Bob',
    },
    {
      title: 'leaves the last message date empty when it is invalid',
      change: { lastMessageDate: 'not a date' },
      field: 8,
      expected: '',
    },
    {
      title: 'strips separators from the last message id',
      change: { lastMessageId: 'm▮9' },
      field: 7,
      expected: 'm9',
    },
    {
      change: { threadId: 't▮1' },
      field: 0,
      expected: 't1',
    },
    {
      title: 'handles an empty subject and snippet',
      change: { subject: '', snippet: '' },
      field: 5,
      expected: '',
    },
  ])('$title', async ({ change, field, expected }) => {
    const line = await gmailFormatRaw({ ...thread, ...change });
    const actual = line.split('▮');

    expect(actual).toHaveLength(9);
    expect(actual).toHaveProperty(field, expected);
  });
});
