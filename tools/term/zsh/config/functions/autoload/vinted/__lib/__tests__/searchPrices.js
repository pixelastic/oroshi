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

  describe('parseCard', () => {
    const card = {
      href: '/items/8061015331-comic-marvel-lug?referrer=catalog',
      title:
        'Comic Marvel LUG – Strange n°111, Condition: Good, 14.00 €, 15.40 €',
      priceText: '14,00 €',
    };

    it('reads every field of a card', () => {
      const expected = {
        id: '8061015331',
        url: 'https://www.vinted.fr/items/8061015331',
        title: 'Comic Marvel LUG – Strange n°111',
        condition: 'Good',
        price: 14,
      };

      const actual = __.parseCard(card);

      expect(actual).toEqual(expected);
    });

    it('keeps the commas of the title', () => {
      const actual = __.parseCard({
        ...card,
        title: 'Dune, tome 1, Condition: Very good, 5.00 €, 5.70 €',
      });

      expect(actual).toHaveProperty('title', 'Dune, tome 1');
      expect(actual).toHaveProperty('condition', 'Very good');
    });

    it.each([
      { title: 'a card without an id', input: { ...card, href: '/member/12' } },
      { title: 'a card without a price', input: { ...card, priceText: '' } },
    ])('skips $title', ({ input }) => {
      const actual = __.parseCard(input);

      expect(actual).toBeNull();
    });
  });
});
