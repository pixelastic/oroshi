import { __, airtableSeparators } from '../separators.js';

describe('airtableSeparators', () => {
  it('reads the field and list separators from the design system icons', async () => {
    vi.spyOn(__, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });

    const actual = await airtableSeparators();

    expect(actual).toEqual({ field: '▮', list: '▯' });
  });
});
