import { __, publishListing } from '../publishListing.js';

describe('publishListing', () => {
  describe('isListingUrl', () => {
    it.each([
      {
        title: 'listing page',
        input: 'https://www.vinted.fr/items/1234567-mon-livre',
        expected: true,
      },
      {
        title: 'listing page without slug',
        input: 'https://www.vinted.fr/items/1234567',
        expected: true,
      },
      {
        title: 'empty form',
        input: 'https://www.vinted.fr/items/new',
        expected: false,
      },
      {
        title: 'login page',
        input: 'https://www.vinted.fr/member/register/select_type',
        expected: false,
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.isListingUrl(input);
      expect(actual).toEqual(expected);
    });
  });

  describe('publishListing', () => {
    it('returns the listing URL once the page shows it', async () => {
      const click = vi.fn();
      const url = 'https://www.vinted.fr/items/42-livre';
      const page = {
        getByTestId: () => ({ first: () => ({ waitFor: vi.fn(), click }) }),
        waitForURL: vi.fn(),
        url: () => url,
      };

      const actual = await publishListing(page);

      expect(click).toHaveBeenCalledTimes(1);
      expect(actual).toEqual(url);
    });

    it('throws without retry when the confirmation never shows', async () => {
      const click = vi.fn();
      const page = {
        getByTestId: () => ({ first: () => ({ waitFor: vi.fn(), click }) }),
        waitForURL: vi.fn().mockImplementation(() => {
          throw new Error('timeout');
        }),
        url: () => 'https://www.vinted.fr/items/new',
      };

      let actual = null;
      try {
        await publishListing(page);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_PUBLISH_NOT_CONFIRMED');
      expect(click).toHaveBeenCalledTimes(1);
    });
  });
});
