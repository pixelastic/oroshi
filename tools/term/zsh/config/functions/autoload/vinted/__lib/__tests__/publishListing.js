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

  describe('hasLeftForm', () => {
    it.each([
      {
        title: 'still on the form',
        input: 'https://www.vinted.fr/items/new',
        expected: false,
      },
      {
        title: 'listing page',
        input: 'https://www.vinted.fr/items/1234567-mon-livre',
        expected: true,
      },
      {
        title: 'wardrobe page',
        input: 'https://www.vinted.fr/member/123-tim',
        expected: true,
      },
      {
        title: 'login page',
        input: 'https://www.vinted.fr/member/register/select_type',
        expected: false,
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.hasLeftForm(input);
      expect(actual).toEqual(expected);
    });
  });

  describe('isUploadResponse', () => {
    it.each([
      {
        title: 'successful upload',
        method: 'POST',
        url: 'https://www.vinted.fr/api/v2/item_upload/items',
        ok: true,
        expected: true,
      },
      {
        title: 'failed upload',
        method: 'POST',
        url: 'https://www.vinted.fr/api/v2/item_upload/items',
        ok: false,
        expected: false,
      },
      {
        title: 'other request',
        method: 'POST',
        url: 'https://www.vinted.fr/api/v2/photos',
        ok: true,
        expected: false,
      },
      {
        title: 'read of the upload endpoint',
        method: 'GET',
        url: 'https://www.vinted.fr/api/v2/item_upload/items',
        ok: true,
        expected: false,
      },
    ])('$title', ({ method, url, ok, expected }) => {
      const response = {
        url: () => url,
        ok: () => ok,
        request: () => ({ method: () => method }),
      };

      const actual = __.isUploadResponse(response);

      expect(actual).toEqual(expected);
    });
  });

  describe('urlFromResponse', () => {
    it.each([
      {
        title: 'url of the item',
        body: { item: { id: 42, url: 'https://www.vinted.fr/items/42-livre' } },
        expected: 'https://www.vinted.fr/items/42-livre',
      },
      {
        title: 'id of the item only',
        body: { item: { id: 42 } },
        expected: 'https://www.vinted.fr/items/42',
      },
      {
        title: 'body without item',
        body: { code: 0 },
        expected: null,
      },
    ])('$title', async ({ body, expected }) => {
      const response = { json: () => body };

      const actual = await __.urlFromResponse(response);

      expect(actual).toEqual(expected);
    });

    it('returns null when the body is not JSON', async () => {
      const response = {
        json: () => {
          throw new Error('not json');
        },
      };

      const actual = await __.urlFromResponse(response);

      expect(actual).toEqual(null);
    });
  });

  describe('findListingUrl', () => {
    let page;
    let cards;
    beforeEach(() => {
      cards = [
        {
          href: '/items/1-autre?referrer=x',
          title: 'Autre livre, Condition: Good',
        },
        {
          href: '/items/2-strange-171?referrer=catalog',
          title: 'Strange n°171 - Lug - mars 1984, Condition: Good, 5.00 €',
        },
      ];
      page = {
        locator: () => ({
          first: () => ({ waitFor: vi.fn() }),
          evaluateAll: () => cards,
        }),
      };
    });

    it('returns the absolute URL of the item whose title starts with the listing title', async () => {
      const actual = await __.findListingUrl(
        page,
        'Strange n°171 - Lug - mars 1984',
      );

      expect(actual).toEqual('https://www.vinted.fr/items/2-strange-171');
    });

    it('returns null when no item has the title', async () => {
      const actual = await __.findListingUrl(page, 'Inconnu');

      expect(actual).toEqual(null);
    });
  });

  describe('publishListing', () => {
    let click;
    let page;
    beforeEach(() => {
      vi.spyOn(__, 'savePage').mockReturnValue('/pages/saved.html');
      click = vi.fn();
      page = {
        getByTestId: () => ({ first: () => ({ waitFor: vi.fn(), click }) }),
        on: vi.fn(),
        waitForResponse: vi.fn().mockReturnValue(new Promise(() => {})),
        waitForURL: vi.fn().mockReturnValue(new Promise(() => {})),
        url: () => 'https://www.vinted.fr/items/new',
      };
    });

    it('returns the listing URL found in the upload response', async () => {
      const url = 'https://www.vinted.fr/items/42-livre';
      page.waitForResponse.mockReturnValue({});
      vi.spyOn(__, 'urlFromResponse').mockReturnValue(url);

      const actual = await publishListing(page, { title: 'Titre' });

      expect(click).toHaveBeenCalledTimes(1);
      expect(actual).toEqual({ url, pagePath: '/pages/saved.html' });
    });

    it('saves the page it lands on once the publication is confirmed', async () => {
      page.waitForURL.mockReturnValue(undefined);
      vi.spyOn(__, 'findListingUrl').mockReturnValue(null);

      await publishListing(page, { title: 'Titre' });

      expect(__.savePage).toHaveBeenCalledTimes(1);
      expect(__).toHaveProperty('savePage.mock.calls.0.0', page);
    });

    it('looks the listing up by title when only the navigation is seen', async () => {
      page.waitForURL.mockReturnValue(undefined);
      page.url = () => 'https://www.vinted.fr/member/123-tim';
      vi.spyOn(__, 'findListingUrl').mockReturnValue(
        'https://www.vinted.fr/items/42-livre',
      );

      const actual = await publishListing(page, { title: 'Titre' });

      expect(__.findListingUrl).toHaveBeenCalledWith(page, 'Titre');
      expect(actual).toEqual({
        url: 'https://www.vinted.fr/items/42-livre',
        pagePath: '/pages/saved.html',
      });
    });

    it('returns the page URL when the lookup finds nothing', async () => {
      page.waitForURL.mockReturnValue(undefined);
      page.url = () => 'https://www.vinted.fr/member/123-tim';
      vi.spyOn(__, 'findListingUrl').mockReturnValue(null);

      const actual = await publishListing(page, { title: 'Titre' });

      expect(actual).toEqual({
        url: 'https://www.vinted.fr/member/123-tim',
        pagePath: '/pages/saved.html',
      });
    });

    it('throws without retry when nothing confirms the publication', async () => {
      page.waitForResponse.mockImplementation(() => {
        throw new Error('timeout');
      });
      page.waitForURL.mockImplementation(() => {
        throw new Error('timeout');
      });

      let actual = null;
      try {
        await publishListing(page, { title: 'Titre' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_PUBLISH_NOT_CONFIRMED');
      expect(click).toHaveBeenCalledTimes(1);
    });
  });
});
