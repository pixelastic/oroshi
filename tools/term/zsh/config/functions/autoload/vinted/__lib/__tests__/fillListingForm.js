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

    it('writes the clipboard, clicks the field, selects its content, then presses Control+V', async () => {
      await __.pasteIn(page, 'description--input', 'line one\nline two');

      expect(calls).toEqual([
        ['write', 'line one\nline two'],
        ['click'],
        ['press', 'Control+A'],
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

  describe('typeIn', () => {
    it('clicks the field, selects its content, then types the text', async () => {
      const calls = [];
      const field = {
        waitFor: vi.fn(),
        click: () => calls.push(['click']),
        pressSequentially: (text) => calls.push(['type', text]),
      };
      const page = {
        getByTestId: () => ({ first: () => field }),
        keyboard: { press: (key) => calls.push(['press', key]) },
      };
      vi.spyOn(__, 'pause').mockReturnValue();

      await __.typeIn(page, 'price-input--input', '15');

      expect(calls).toEqual([
        ['click'],
        ['press', 'Control+A'],
        ['type', '15'],
      ]);
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

  describe('fillListingForm partial listing', () => {
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'setPhotos').mockReturnValue();
      vi.spyOn(__, 'pickCategory').mockReturnValue();
      vi.spyOn(__, 'pickLanguage').mockReturnValue();
      vi.spyOn(__, 'pickCondition').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
      vi.spyOn(__, 'pasteIn').mockReturnValue();
    });

    it('fills only the fields the listing has', async () => {
      await fillListingForm({}, { price: 8, condition: 'Good' });

      expect(__.typeIn).toHaveBeenCalledWith({}, 'price-input--input', '8');
      expect(__.pickCondition).toHaveBeenCalledWith({}, 'Good');
      expect(__.setPhotos).not.toHaveBeenCalled();
      expect(__.pasteIn).not.toHaveBeenCalled();
      expect(__.pickCategory).not.toHaveBeenCalled();
    });
  });

  describe('fillListingForm timings', () => {
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'setPhotos').mockReturnValue();
      vi.spyOn(__, 'pickCategory').mockReturnValue();
      vi.spyOn(__, 'pickCondition').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
      vi.spyOn(__, 'pasteIn').mockReturnValue();
    });

    it('returns the duration of each step it ran, in order', async () => {
      const listing = {
        photos: ['/a.jpg'],
        title: 'Title',
        price: 8,
      };

      const actual = await fillListingForm({}, listing);

      expect(actual.map(({ step }) => step)).toEqual([
        'cookies',
        'photos',
        'title',
        'price',
      ]);
      actual.forEach(({ durationInMs }) => {
        expect(durationInMs).toBeGreaterThanOrEqual(0);
      });
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

  describe('pickCategory', () => {
    let page;
    beforeEach(() => {
      page = {};
      vi.spyOn(__, 'pause').mockReturnValue();
      vi.spyOn(__, 'openCategoryPicker').mockReturnValue();
      vi.spyOn(__, 'pickCategoryLevel').mockReturnValue();
      vi.spyOn(__, 'closeCategoryPicker').mockReturnValue();
    });

    it('does nothing when Vinted already suggested the leaf category', async () => {
      vi.spyOn(__, 'readCategory').mockReturnValue(
        'Comics, manga & graphic novels',
      );

      await __.pickCategory(page, [
        'Books & Media',
        'Books',
        'Comics, manga & graphic novels',
      ]);

      expect(__.openCategoryPicker).not.toHaveBeenCalled();
      expect(__.pickCategoryLevel).not.toHaveBeenCalled();
    });

    it('walks every level when the category is empty', async () => {
      vi.spyOn(__, 'readCategory').mockReturnValue('');

      await __.pickCategory(page, ['Books & Media', 'Books']);

      expect(__.pickCategoryLevel.mock.calls.map(([, label]) => label)).toEqual(
        ['Books & Media', 'Books'],
      );
    });

    it('stops walking once Vinted sets the leaf category itself', async () => {
      vi.spyOn(__, 'readCategory')
        .mockReturnValueOnce('')
        .mockReturnValueOnce('')
        .mockReturnValue('Comics');

      await __.pickCategory(page, ['Books & Media', 'Books', 'Comics']);

      expect(__.pickCategoryLevel).toHaveBeenCalledTimes(1);
    });

    it('closes the picker Vinted left open after setting the category itself', async () => {
      vi.spyOn(__, 'readCategory')
        .mockReturnValueOnce('')
        .mockReturnValue('Fiction');

      await __.pickCategory(page, ['Books & Media', 'Books', 'Fiction']);

      expect(__.pickCategoryLevel).not.toHaveBeenCalled();
      expect(__.closeCategoryPicker).toHaveBeenCalledTimes(1);
    });
  });

  describe('fillListingForm without book fields', () => {
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'setPhotos').mockReturnValue();
      vi.spyOn(__, 'pickCategory').mockReturnValue();
      vi.spyOn(__, 'pickLanguage').mockReturnValue();
      vi.spyOn(__, 'pickCondition').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
      vi.spyOn(__, 'pasteIn').mockReturnValue();
    });

    it('skips the isbn and the language outside the Books categories', async () => {
      const listing = {
        title: 'Title',
        category: ['Books & Media', 'Magazines'],
        isbn: '0000000000000',
        language: 'French',
      };

      await fillListingForm({}, listing);

      expect(__.pasteIn.mock.calls.map(([, testId]) => testId)).toEqual([
        'title--input',
      ]);
      expect(__.pickLanguage).not.toHaveBeenCalled();
    });

    it('fills the isbn and the language in the Books categories', async () => {
      const listing = {
        category: ['Books & Media', 'Books', 'Fiction'],
        isbn: '0000000000000',
        language: 'French',
      };

      await fillListingForm({}, listing);

      expect(__.pasteIn.mock.calls.map(([, testId]) => testId)).toEqual([
        'isbn--input',
      ]);
      expect(__.pickLanguage).toHaveBeenCalledWith({}, 'French');
    });
  });

  describe('pickColours', () => {
    it('opens the colour picker, clicks each colour by its label, then closes it', async () => {
      const calls = [];
      const picker = {
        waitFor: vi.fn(),
        click: () => calls.push(['click picker']),
      };
      const page = {
        getByTestId: () => ({ first: () => picker }),
        locator: (selector) => ({
          filter: ({ hasText }) => ({
            first: () => ({
              waitFor: vi.fn(),
              click: () => calls.push(['click', selector, hasText.source]),
            }),
          }),
        }),
        keyboard: { press: (key) => calls.push(['press', key]) },
      };
      vi.spyOn(__, 'pause').mockReturnValue();

      await __.pickColours(page, ['Multi', 'Gold']);

      expect(calls).toEqual([
        ['click picker'],
        ['click', '[data-testid^="color-"]', '^Multi$'],
        ['click', '[data-testid^="color-"]', '^Gold$'],
        ['press', 'Escape'],
      ]);
    });
  });

  describe('fillListingForm colours', () => {
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'pickColours').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
    });

    it('picks the colours when the listing has some', async () => {
      await fillListingForm({}, { colours: ['Multi'] });

      expect(__.pickColours).toHaveBeenCalledWith({}, ['Multi']);
    });

    it('does not pick colours when the listing has none', async () => {
      await fillListingForm({}, { price: 5 });

      expect(__.pickColours).not.toHaveBeenCalled();
    });
  });

  describe('pickBrand', () => {
    it('opens the brand picker, searches the brand, then clicks it', async () => {
      const calls = [];
      const field = (name) => ({
        waitFor: vi.fn(),
        click: () => calls.push(['click', name]),
        fill: (text) => calls.push(['fill', name, text]),
      });
      const page = {
        getByTestId: (testId) => ({ first: () => field(testId) }),
        getByText: (label, options) => ({
          first: () => ({
            waitFor: vi.fn(),
            click: () => calls.push(['click text', label, options.exact]),
          }),
        }),
      };
      vi.spyOn(__, 'pause').mockReturnValue();

      await __.pickBrand(page, 'Inconnu');

      expect(calls).toEqual([
        ['click', 'brand-select-dropdown-input'],
        ['click text', 'Inconnu', true],
      ]);
    });
  });

  describe('fillListingForm brand', () => {
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'pickBrand').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
    });

    it('picks the brand when the listing has one', async () => {
      await fillListingForm({}, { brand: 'Inconnu' });

      expect(__.pickBrand).toHaveBeenCalledWith({}, 'Inconnu');
    });

    it('does not pick a brand when the listing has none', async () => {
      await fillListingForm({}, { price: 5 });

      expect(__.pickBrand).not.toHaveBeenCalled();
    });
  });

  describe('fillListingForm platform and rating', () => {
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'pickPlatform').mockReturnValue();
      vi.spyOn(__, 'pickRating').mockReturnValue();
      vi.spyOn(__, 'typeIn').mockReturnValue();
    });

    it('picks the platform and the rating when the listing has them', async () => {
      await fillListingForm(
        {},
        { platform: 'Sega Dreamcast', rating: 'Unspecified' },
      );

      expect(__.pickPlatform).toHaveBeenCalledWith({}, 'Sega Dreamcast');
      expect(__.pickRating).toHaveBeenCalledWith({}, 'Unspecified');
    });

    it('picks neither when the listing has none', async () => {
      await fillListingForm({}, { price: 5 });

      expect(__.pickPlatform).not.toHaveBeenCalled();
      expect(__.pickRating).not.toHaveBeenCalled();
    });
  });

  describe('pickParcelSize', () => {
    it.each([
      { size: 'Small', testId: '1-package-size--cell' },
      { size: 'Medium', testId: '2-package-size--cell' },
      { size: 'Large', testId: '3-package-size--cell' },
    ])('clicks the cell of the $size parcel', async ({ size, testId }) => {
      const calls = [];
      const page = {
        getByTestId: (id) => ({
          first: () => ({
            waitFor: vi.fn(),
            click: () => calls.push(['click', id]),
          }),
        }),
      };
      vi.spyOn(__, 'pause').mockReturnValue();

      await __.pickParcelSize(page, size);

      expect(calls).toEqual([['click', testId]]);
    });
  });

  describe('fillListingForm parcel size', () => {
    let listing;
    beforeEach(() => {
      vi.spyOn(__, 'acceptCookies').mockReturnValue();
      vi.spyOn(__, 'setPhotos').mockReturnValue();
      vi.spyOn(__, 'pickCategory').mockReturnValue();
      vi.spyOn(__, 'pickCondition').mockReturnValue();
      vi.spyOn(__, 'pickParcelSize').mockReturnValue();
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

    it('picks the parcel size when the listing has one', async () => {
      await fillListingForm({}, { ...listing, parcelSize: 'Small' });

      expect(__.pickParcelSize).toHaveBeenCalledWith({}, 'Small');
    });

    it('does not pick a parcel size when the listing has none', async () => {
      await fillListingForm({}, listing);

      expect(__.pickParcelSize).not.toHaveBeenCalled();
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
