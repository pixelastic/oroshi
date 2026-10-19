import { formatPrice } from '../formatPrice.js';

describe('formatPrice', () => {
  it.each([
    { input: 6.5, expected: '6.50 €' },
    { input: 10, expected: '10.00 €' },
    { input: 12.999, expected: '13.00 €' },
  ])('formats $input as $expected', ({ input, expected }) => {
    const actual = formatPrice(input);
    expect(actual).toEqual(expected);
  });
});
