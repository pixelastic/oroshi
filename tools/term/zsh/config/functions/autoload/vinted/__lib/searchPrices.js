import { _ } from 'golgoth';
import { ensureLoggedIn } from './ensureLoggedIn.js';

export let __;

const SEARCH_URL = 'https://www.vinted.fr/catalog';
const ITEM_LINK_SELECTOR = 'a[href*="/items/"][data-testid$="--overlay-link"]';
const PRICE_SELECTOR_SUFFIX = '--price-text';
const ITEM_PATH_PATTERN = /\/items\/(\d+)/;
const ITEM_URL = 'https://www.vinted.fr/items';
const TITLE_PATTERN = /^(.*), Condition: ([^,]+),/;

/**
 * Search Vinted by keywords and extract the asking price of each result
 * Prices are what sellers ask, not what buyers paid.
 * @param {object} page - Playwright page, logged in
 * @param {string} keywords - Search keywords
 * @returns {Promise<object[]>} Listings as { id, url, title, condition, price }
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
          title: link.getAttribute('title') ?? '',
          priceText: priceElement?.textContent ?? '',
        };
      }),
    PRICE_SELECTOR_SUFFIX,
  );

  return _.chain(cards).map(__.parseCard).compact().value();
}

__ = {
  /**
   * Read a search result card
   * @param {object} card - Raw card as { href, title, priceText }
   * @returns {object|null} Listing as { id, url, title, condition, price }, or null when the card has no id or no price
   */
  parseCard(card) {
    const { href, title, priceText } = card;
    const id = __.parseId(href);
    const price = __.parsePrice(priceText);
    if (!id || !_.isFinite(price)) {
      return null;
    }
    return {
      id,
      url: `${ITEM_URL}/${id}`,
      ...__.parseTitle(title),
      price,
    };
  },
  /**
   * Split a card title into the item title and its condition
   * @param {string} text - Card title like "Dune, Condition: Good, 5.00 €, 5.70 €"
   * @returns {object} Title and condition, as { title, condition }
   */
  parseTitle(text) {
    const [, title = text, condition = ''] = TITLE_PATTERN.exec(text) ?? [];
    return { title, condition };
  },
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
