import { parseRaw } from '../parseRaw.js';
import { __ as separatorsInternals } from '../separators.js';
import { __ as threadListRaw } from '../thread/threadListRaw.js';

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
      summary: {
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
      title: 'gives back a read summary without authors',
      summary: {
        id: 'c2',
        date: '',
        count: 1,
        authors: [],
        subject: '',
        snippet: '',
        unread: false,
      },
    },
  ])('$title', async ({ summary }) => {
    const actual = await parseRaw(threadListRaw.toLine(summary));

    expect(actual).toEqual(summary);
  });
});
