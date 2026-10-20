import { parsePostedUrl } from '../parsePostedUrl.js';

describe('parsePostedUrl', () => {
  it('extracts the URL from the last output line', () => {
    const input = [
      'fill: 120ms',
      'Listing published: https://www.vinted.fr/items/1-dune',
      '{"url":"https://www.vinted.fr/items/1-dune"}',
    ].join('\n');

    const actual = parsePostedUrl(input);

    expect(actual).toEqual('https://www.vinted.fr/items/1-dune');
  });

  it('ignores trailing blank lines', () => {
    const input = '{"url":"https://www.vinted.fr/items/2-asterix"}\n\n';

    const actual = parsePostedUrl(input);

    expect(actual).toEqual('https://www.vinted.fr/items/2-asterix');
  });

  it.each([
    { title: 'empty output', input: '' },
    { title: 'a last line that is not JSON', input: 'Screenshot saved' },
    { title: 'a JSON line with no url', input: '{"id":3}' },
  ])('throws on $title', ({ input }) => {
    let actual = null;
    try {
      parsePostedUrl(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'VINTED_LISTING_URL_NOT_FOUND');
  });
});
