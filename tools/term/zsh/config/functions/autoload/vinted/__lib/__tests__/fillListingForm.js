import { __, fillListingForm } from '../fillListingForm.js';

describe('fillListingForm', () => {
  describe('pasteIn', () => {
    let calls;
    let page;
    let fieldValue;
    beforeEach(() => {
      calls = [];
      fieldValue = 'line one\nline two';
      vi.spyOn(__, 'writeClipboard').mockImplementation((text) =>
        calls.push(['write', text]),
      );
      const field = {
        waitFor: vi.fn(),
        click: () => calls.push(['click']),
        inputValue: () => fieldValue,
      };
      page = {
        getByTestId: () => ({ first: () => field }),
        keyboard: { press: (key) => calls.push(['press', key]) },
      };
      vi.spyOn(__, 'pause').mockReturnValue();
    });

    it('writes the clipboard, clicks the field, then presses Control+V', async () => {
      await __.pasteIn(page, 'description--input', 'line one\nline two');

      expect(calls).toEqual([
        ['write', 'line one\nline two'],
        ['click'],
        ['press', 'Control+V'],
      ]);
    });

    it('resolves when the field value equals the text', async () => {
      let actual = null;
      try {
        await __.pasteIn(page, 'description--input', 'line one\nline two');
      } catch (error) {
        actual = error;
      }

      expect(actual).toEqual(null);
    });

    it('throws when the field value differs from the text', async () => {
      fieldValue = 'line one';

      let actual = null;
      try {
        await __.pasteIn(page, 'description--input', 'line one\nline two');
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_PASTE_FAILED');
      expect(actual).toHaveProperty(
        'message',
        'Pasting in "description--input" failed, the field does not hold the expected text',
      );
    });
  });

  describe('fillListingForm', () => {
    it('pastes the description and types the other fields', async () => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'setPhotos').mockReturnValue();
      vi.spyOn(__, 'pickCategory').mockReturnValue();
      vi.spyOn(__, 'pickCondition').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
      vi.spyOn(__, 'pasteIn').mockReturnValue();
      const listing = {
        photos: ['/a.jpg'],
        title: 'Title',
        description: 'Line one\nLine two',
        category: ['Books'],
        isbn: '978',
        condition: 'Good',
        price: 6.5,
      };

      await fillListingForm({}, listing);

      expect(__.pasteIn).toHaveBeenCalledTimes(1);
      expect(__.pasteIn).toHaveBeenCalledWith(
        {},
        'description--input',
        'Line one\nLine two',
      );
      expect(__.typeIn.mock.calls.map(([, testId]) => testId)).toEqual([
        'title--input',
        'isbn--input',
        'price-input--input',
      ]);
    });
  });

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
