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

  describe('field', () => {
    it('throws an error naming the missing field', async () => {
      const waitFor = vi.fn().mockImplementation(() => {
        throw new Error('timeout');
      });
      const locator = { first: () => ({ waitFor }) };
      const page = { getByTestId: () => locator };

      let actual = null;
      try {
        await __.field(page, 'title--input');
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_FORM_FIELD_MISSING');
      expect(actual).toHaveProperty(
        'message',
        'Form field "title--input" not found, the Vinted form may have changed',
      );
    });
  });
});
