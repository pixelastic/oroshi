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

  describe('pickLanguage', () => {
    it('opens the language picker, then clicks the option with the label', async () => {
      const calls = [];
      const option = { click: () => calls.push(['click option']) };
      const list = {
        getByText: (label, options) => {
          calls.push(['getByText', label, options]);
          return { first: () => ({ waitFor: vi.fn(), ...option }) };
        },
      };
      const fields = {
        'isbn-language_book-single-list_search-input': {
          waitFor: vi.fn(),
          click: () => calls.push(['click picker']),
        },
        'isbn-language_book-single-list_search-content': {
          waitFor: vi.fn(),
          ...list,
        },
      };
      const page = {
        getByTestId: (testId) => ({ first: () => fields[testId] }),
      };
      vi.spyOn(__, 'pause').mockReturnValue();

      await __.pickLanguage(page, 'French');

      expect(calls).toEqual([
        ['click picker'],
        ['getByText', 'French', { exact: true }],
        ['click option'],
      ]);
    });
  });

  describe('fillListingForm', () => {
    it('pastes the title, the description and the isbn, and types the price', async () => {
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

      expect(__).toHaveProperty('pasteIn.mock.calls', [
        [{}, 'title--input', 'Title'],
        [{}, 'description--input', 'Line one\nLine two'],
        [{}, 'isbn--input', '978'],
      ]);
      expect(__.typeIn.mock.calls.map(([, testId]) => testId)).toEqual([
        'price-input--input',
      ]);
    });
  });

  describe('fillListingForm language', () => {
    let listing;
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'setPhotos').mockReturnValue();
      vi.spyOn(__, 'pickCategory').mockReturnValue();
      vi.spyOn(__, 'pickLanguage').mockReturnValue();
      vi.spyOn(__, 'pickCondition').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
      vi.spyOn(__, 'pasteIn').mockReturnValue();
      listing = {
        photos: ['/a.jpg'],
        title: 'Title',
        description: 'Text',
        category: ['Books'],
        isbn: '0000000000000',
        condition: 'Good',
        price: 5,
      };
    });

    it('picks the language when the listing has one', async () => {
      await fillListingForm({}, { ...listing, language: 'French' });

      expect(__.pickLanguage).toHaveBeenCalledWith({}, 'French');
    });

    it('does not pick a language when the listing has none', async () => {
      await fillListingForm({}, listing);

      expect(__.pickLanguage).not.toHaveBeenCalled();
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
