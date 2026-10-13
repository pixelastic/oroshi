import { __, pageRemove } from '../pageRemove.js';

describe('pageRemove', () => {
  const pageId = '11111111-1111-1111-1111-111111111111';
  const formatted = { id: pageId, url: 'u', properties: {}, markdown: '# A' };

  beforeEach(() => {
    vi.spyOn(__, 'pageReplace').mockReturnValue(formatted);
  });

  it.each([
    {
      title: 'replaces the old text by an empty string',
      input: { old: 'Obsolete paragraph' },
      expected: { old: 'Obsolete paragraph', oldFile: undefined, new: '' },
    },
    {
      title: 'reads the old text from a file when given',
      input: { old: 'Inline', oldFile: './old.md' },
      expected: { old: 'Inline', oldFile: './old.md', new: '' },
    },
  ])('$title', async ({ input, expected }) => {
    await pageRemove({ pageId, ...input });

    expect(__.pageReplace).toHaveBeenCalledWith({ pageId, ...expected });
  });

  it('accepts a URL as the Page id', async () => {
    const url = `https://www.notion.so/Meetup-${pageId.replaceAll('-', '')}`;

    await pageRemove({ pageId: url, old: 'x' });

    expect(__.pageReplace).toHaveBeenCalledWith(
      expect.objectContaining({ pageId: url }),
    );
  });

  it('returns the updated Page, as read', async () => {
    const actual = await pageRemove({ pageId, old: 'x' });

    expect(actual).toEqual(formatted);
  });
});
