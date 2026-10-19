import { _ } from 'golgoth';
import { ensureLoggedIn } from './ensureLoggedIn.js';

export let __;

const SEARCH_URL = 'https://www.vinted.fr/catalog';
const ITEM_LINK_SELECTOR = 'a[href*="/items/"][data-testid$="--overlay-link"]';
const PRICE_SELECTOR_SUFFIX = '--price-text';
const ITEM_PATH_PATTERN = /\/items\/(\d+)/;

/**
 * Search Vinted by keywords and extract the asking price of each result
 * Prices are what sellers ask, not what buyers paid.
 * @param {object} page - Playwright page, logged in
 * @param {string} keywords - Search keywords
 * @returns {Promise<object[]>} Listings as { id, price }
 */
export async function searchPrices(page, keywords) {
  const searchUrl = `${SEARCH_URL}?${new URLSearchParams({ search_text: keywords })}`;
  await page.goto(searchUrl);
  await ensureLoggedIn(page);
  await page.locator(ITEM_LINK_SELECTOR).first().waitFor();

  const cards = await page.locator(ITEM_LINK_SELECTOR).evaluateAll(
    (links, priceSuffix) =>
      links.map((link) => {
        const testId = link.getAttribute('data-testid');
        const priceTestId = testId.replace('--overlay-link', priceSuffix);
        const priceElement = document.querySelector(
          `[data-testid="${priceTestId}"]`,
        );
        return {
          href: link.getAttribute('href'),
          priceText: priceElement?.textContent ?? '',
        };
      }),
    PRICE_SELECTOR_SUFFIX,
  );

  return _.chain(cards)
    .map((card) => ({
      id: __.parseId(card.href),
      price: __.parsePrice(card.priceText),
    }))
    .filter(({ id, price }) => id && _.isFinite(price))
    .value();
}

__ = {
  /**
   * Extract the listing id from a listing link
   * @param {string} href - Link like /items/123-some-title
   * @returns {string|null} Listing id, or null when the link has none
   */
  parseId(href) {
    return _.get(ITEM_PATH_PATTERN.exec(href), 1, null);
  },
  /**
   * Convert a displayed price to a number
   * @param {string} text - Displayed price, like "12,50 €"
   * @returns {number} Price, or NaN when the text has no price
   */
  parsePrice(text) {
    const cleaned = _.chain(text)
      .replace(',', '.')
      .replace(/[^\d.]/g, '')
      .value();
    return _.toNumber(cleaned === '' ? Number.NaN : cleaned);
  },
};
