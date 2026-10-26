import { __, separators } from '../separators.js';

describe('separators', () => {
  beforeEach(() => {
    vi.spyOn(__, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
  });

  it('reads the separators of the design system', async () => {
    const actual = await separators();

    expect(actual).toEqual({ field: '▮', list: '▯' });
  });
});
