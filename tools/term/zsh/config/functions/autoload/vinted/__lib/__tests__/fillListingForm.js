import { __ } from '../fillListingForm.js';

describe('fillListingForm', () => {
  describe('formatPrice', () => {
    it.each([
      { input: 6.5, expected: '6,5' },
      { input: 10, expected: '10' },
      { input: 12.99, expected: '12,99' },
    ])('formats $input as $expected', ({ input, expected }) => {
      const actual = __.formatPrice(input);
      expect(actual).toEqual(expected);
    });
  });
});
