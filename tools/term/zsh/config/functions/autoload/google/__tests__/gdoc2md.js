import { __, gdoc2md } from '../__lib/gdoc2md.js';

describe('slugify', () => {
  it.each([
    { input: 'Hello World', expected: 'hello-world' },
    { input: 'Café & Résumé', expected: 'cafe-resume' },
    { input: '  Spaces  Everywhere  ', expected: 'spaces-everywhere' },
    {
      input: 'Monolithic vs. Distributed Agents: How to Choose',
      expected: 'monolithic-vs-distributed-agents-how-to-choose',
    },
  ])('$input -> $expected', ({ input, expected }) => {
    expect(__.slugify(input)).toEqual(expected);
  });
});

describe('replaceImageUrls', () => {
  it.each([
    {
      title: 'replaces URL inside ![alt](url) with local filename',
      input: 'Some text ![photo](https://example.com/img.png) more text',
      mapping: { 'https://example.com/img.png': 'image-1.png' },
      expected: 'Some text ![photo](image-1.png) more text',
    },
    {
      title: 'does not replace the same URL appearing as bare text',
      input:
        'See https://example.com/img.png and ![photo](https://example.com/img.png)',
      mapping: { 'https://example.com/img.png': 'image-1.png' },
      expected: 'See https://example.com/img.png and ![photo](image-1.png)',
    },
    {
      title: 'handles multiple images',
      input: '![a](https://a.com/1.png) text ![b](https://b.com/2.png)',
      mapping: {
        'https://a.com/1.png': 'image-1.png',
        'https://b.com/2.png': 'image-2.png',
      },
      expected: '![a](image-1.png) text ![b](image-2.png)',
    },
  ])('$title', ({ input, mapping, expected }) => {
    const actual = __.replaceImageUrls(input, mapping);
    expect(actual).toEqual(expected);
  });
});

describe('gdoc2md', () => {
  beforeEach(() => {
    vi.spyOn(__, 'gdocRead').mockReturnValue({
      markdown: '# Hello\n\n![diagram](https://example.com/img.png)\n',
      images: [{ contentUri: 'https://example.com/img.png' }],
      title: 'My Document',
    });
  });

  it('returns correct shape with local filenames', async () => {
    const actual = await gdoc2md('abc123');
    expect(actual).toEqual({
      markdown: '# Hello\n\n![diagram](image-1.png)\n',
      images: [
        { contentUri: 'https://example.com/img.png', filename: 'image-1.png' },
      ],
      title: 'My Document',
      slug: 'my-document',
    });
  });
});
