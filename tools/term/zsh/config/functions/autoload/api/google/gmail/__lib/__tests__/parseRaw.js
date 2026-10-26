import { __ as messageListRaw } from '../message/messageListRaw.js';
import { parseRaw } from '../parseRaw.js';
import { __ as separatorsInternals } from '../separators.js';

describe('parseRaw', () => {
  beforeEach(() => {
    vi.spyOn(separatorsInternals, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
  });

  it.each([
    {
      title: 'gives back the fields of a row',
      message: {
        id: 'c1',
        date: '2026-10-03T19:26:59.000Z',
        count: 3,
        authors: ['Bob', 'Alice Martin'],
        subject: 'Quarterly report',
        snippet: 'Please find the report attached',
        unread: true,
      },
    },
    {
      title: 'gives back a read message without authors',
      message: {
        id: 'c2',
        date: '',
        count: 1,
        authors: [],
        subject: '',
        snippet: '',
        unread: false,
      },
    },
  ])('$title', async ({ message }) => {
    const actual = await parseRaw(messageListRaw.toLine(message));

    expect(actual).toEqual(message);
  });
});
