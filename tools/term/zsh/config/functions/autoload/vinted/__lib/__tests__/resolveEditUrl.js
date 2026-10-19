import { resolveEditUrl } from '../resolveEditUrl.js';

describe('resolveEditUrl', () => {
  it.each([
    { input: '123456', expected: 'https://www.vinted.fr/items/123456/edit' },
    {
      input: 'https://www.vinted.fr/items/123456-le-seigneur-des-anneaux',
      expected: 'https://www.vinted.fr/items/123456/edit',
    },
    {
      input: 'https://www.vinted.fr/items/123456/edit',
      expected: 'https://www.vinted.fr/items/123456/edit',
    },
  ])('resolves $input', ({ input, expected }) => {
    const actual = resolveEditUrl(input);

    expect(actual).toEqual(expected);
  });

  it.each(['', 'abc', 'https://www.vinted.fr/items/new'])(
    'throws on "%s"',
    (input) => {
      let actual = null;
      try {
        resolveEditUrl(input);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_ID_INVALID');
      expect(actual).toHaveProperty(
        'message',
        `"${input}" is neither a listing id nor a listing URL`,
      );
    },
  );
});
