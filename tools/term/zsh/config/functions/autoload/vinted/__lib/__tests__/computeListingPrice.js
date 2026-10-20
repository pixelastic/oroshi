import { computeListingPrice } from '../computeListingPrice.js';

/**
 * Build kept rows from prices
 * @param {number[]} prices - Asking prices
 * @returns {object[]} Rows
 */
function rowsOf(prices) {
  return prices.map((price, index) => ({ id: `${index}`, price }));
}

describe('computeListingPrice', () => {
  describe('price', () => {
    it.each([
      { title: '80 percent of the median', prices: [10, 10, 10], expected: 8 },
      { title: 'rounded to the euro', prices: [11, 11, 11], expected: 9 },
      { title: 'never below 2 euros', prices: [1, 1, 1], expected: 2 },
    ])('$title', ({ prices, expected }) => {
      const actual = computeListingPrice(rowsOf(prices), { basis: 'isbn' });

      expect(actual).toHaveProperty('price', expected);
    });

    it.each([
      {
        title: 'middle value of an odd count',
        prices: [30, 10, 20],
        median: 20,
      },
      {
        title: 'mean of the two middle values of an even count',
        prices: [10, 20, 30, 40],
        median: 25,
      },
    ])('uses the $title', ({ prices, median }) => {
      const actual = computeListingPrice(rowsOf(prices), { basis: 'isbn' });

      expect(actual).toHaveProperty('median', median);
      expect(actual).toHaveProperty('price', Math.round(0.8 * median));
    });
  });

  describe('uncertainty', () => {
    it.each([
      {
        title: 'fewer than 3 rows',
        prices: [10, 10],
        basis: 'isbn',
        expected: true,
      },
      {
        title: 'the few basis',
        prices: [10, 10, 10],
        basis: 'few',
        expected: true,
      },
      {
        title: 'only 3 rows or more with a firm basis',
        prices: [10, 10, 10],
        basis: 'isbn',
        expected: false,
      },
    ])('flags $title as $expected', ({ prices, basis, expected }) => {
      const actual = computeListingPrice(rowsOf(prices), { basis });

      expect(actual).toHaveProperty('isUncertain', expected);
    });
  });

  it('returns the price, median, count and basis', () => {
    const actual = computeListingPrice(rowsOf([10, 20, 30]), {
      basis: 'title',
    });

    expect(actual).toEqual({
      price: 16,
      median: 20,
      count: 3,
      basis: 'title',
      isUncertain: false,
    });
  });

  it('throws a clear error on an empty array', () => {
    let actual = null;
    try {
      computeListingPrice([], { basis: 'isbn' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'VINTED_PRICE_NO_RESULT');
  });
});
