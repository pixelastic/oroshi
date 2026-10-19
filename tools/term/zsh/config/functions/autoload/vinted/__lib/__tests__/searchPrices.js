import { __ } from '../searchPrices.js';

describe('searchPrices', () => {
  describe('parsePrice', () => {
    it.each([
      { input: '12,50 €', expected: 12.5 },
      { input: '8,00 €', expected: 8 },
      { input: '1 200,00 €', expected: 1200 },
    ])('reads $input', ({ input, expected }) => {
      const actual = __.parsePrice(input);

      expect(actual).toEqual(expected);
    });

    it('returns NaN when the text has no price', () => {
      const actual = __.parsePrice('');

      expect(actual).toBeNaN();
    });
  });

  describe('parseId', () => {
    it.each([
      { input: '/items/123456-dune-frank-herbert', expected: '123456' },
      {
        input: 'https://www.vinted.fr/items/42-livre?referrer=x',
        expected: '42',
      },
      { input: '/member/12', expected: null },
    ])('reads $input', ({ input, expected }) => {
      const actual = __.parseId(input);

      expect(actual).toEqual(expected);
    });
  });
});
