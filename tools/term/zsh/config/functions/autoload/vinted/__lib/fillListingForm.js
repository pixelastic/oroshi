import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
import { findField } from './findField.js';
import { waitForLocator } from './waitForLocator.js';
import { writeClipboard } from './writeClipboard.js';

export let __;

const COOKIE_TIMEOUT_IN_MS = 3000;
const PAUSE_RANGE_IN_MS = [400, 1200];
const TYPING_DELAY_IN_MS = 25;
const COOKIE_BUTTON = '#onetrust-accept-btn-handler';
const CONDITION_RADIOS = {
  'New with tags': 6,
  'New without tags': 1,
  'Very good': 2,
  Good: 3,
  Satisfactory: 4,
};

/**
 * Fill the Vinted listing form, without publishing it
 * The page must already show the listing form of a logged-in session. Stops
 * with an error as soon as a form field is missing.
 * @param {object} page - Playwright page showing the listing form
 * @param {object} listing - Listing returned by parseListing
 */
export async function fillListingForm(page, listing) {
  await __.acceptCookies(page);

  await __.setPhotos(page, listing.photos);
  await __.pasteIn(page, 'title--input', listing.title);
  await __.pasteIn(page, 'description--input', listing.description);
  await __.pickCategory(page, listing.category);
  await __.pasteIn(page, 'isbn--input', listing.isbn);
  if (listing.language) {
    await __.pickLanguage(page, listing.language);
  }
  await __.pickCondition(page, listing.condition);
  await __.typeIn(page, 'price-input--input', __.formatPrice(listing.price));
}

__ = {
  /**
   * Wait a random human-like delay
   * @param {object} page - Playwright page
   */
  async pause(page) {
    await page.waitForTimeout(_.random(...PAUSE_RANGE_IN_MS));
  },

  /**
   * Accept the cookie banner when it covers the form
   * @param {object} page - Playwright page
   */
  async acceptCookies(page) {
    const button = page.locator(COOKIE_BUTTON);
    try {
      await button.waitFor({ timeout: COOKIE_TIMEOUT_IN_MS });
    } catch {
      // No banner, nothing to accept
      return;
    }
    await button.click();
    await __.pause(page);
  },

  /**
   * Upload the photos
   * @param {object} page - Playwright page
   * @param {string[]} photos - Absolute photo paths
   */
  async setPhotos(page, photos) {
    // The file input is hidden, so it only needs to be attached
    const input = await findField(page, 'add-photos-input', 'attached');
    await input.setInputFiles(photos);
    await __.pause(page);
  },

  /**
   * Type a text in a form field
   * @param {object} page - Playwright page
   * @param {string} testId - data-testid of the field
   * @param {string} text - Text to type
   */
  async typeIn(page, testId, text) {
    const input = await findField(page, testId);
    await input.click();
    await input.pressSequentially(text, { delay: TYPING_DELAY_IN_MS });
    await __.pause(page);
  },

  /**
   * Paste a text in a form field, through the clipboard
   * Fails when the field does not hold the text afterwards. There is no typing
   * fallback.
   * @param {object} page - Playwright page
   * @param {string} testId - data-testid of the field
   * @param {string} text - Text to paste
   */
  async pasteIn(page, testId, text) {
    const input = await findField(page, testId);
    await __.writeClipboard(text);
    await input.click();
    await page.keyboard.press('Control+V');
    await __.pause(page);

    const value = await input.inputValue();
    if (value !== text) {
      throw firostError(
        'VINTED_PASTE_FAILED',
        `Pasting in "${testId}" failed, the field does not hold the expected text`,
      );
    }
  },

  /**
   * Walk the category picker, one label per level
   * @param {object} page - Playwright page
   * @param {string[]} labels - Category labels, from the root to the leaf
   */
  async pickCategory(page, labels) {
    const picker = await findField(page, 'catalog-select-dropdown-input');
    await picker.click();
    await __.pause(page);

    // Each level opens only after the previous click, so one at a time
    await pMap(labels, (label) => __.pickCategoryLevel(page, label), {
      concurrency: 1,
    });
  },

  /**
   * Click one label of the category picker
   * @param {object} page - Playwright page
   * @param {string} label - Label to click
   */
  async pickCategoryLevel(page, label) {
    const list = await findField(page, 'category-list');
    const item = await waitForLocator(
      list
        .locator('li')
        .filter({ has: page.getByText(label, { exact: true }) }),
      `Category "${label}" not found in the category picker`,
    );
    await item.click();
    await __.pause(page);
  },

  /**
   * Select the book language, once the ISBN field makes it appear
   * @param {object} page - Playwright page
   * @param {string} language - Language label, in English (e.g. "French")
   */
  async pickLanguage(page, language) {
    const picker = await findField(
      page,
      'isbn-language_book-single-list_search-input',
    );
    await picker.click();
    await __.pause(page);

    const list = await findField(
      page,
      'isbn-language_book-single-list_search-content',
    );
    const option = await waitForLocator(
      list.getByText(language, { exact: true }),
      `Language "${language}" not found in the language picker`,
    );
    await option.click();
    await __.pause(page);
  },

  /**
   * Select the condition radio
   * @param {object} page - Playwright page
   * @param {string} condition - One of the five English condition labels
   */
  async pickCondition(page, condition) {
    const container = await findField(
      page,
      'category-condition-single-list-input',
    );
    await container.click();
    await __.pause(page);

    const radio = await findField(
      page,
      `condition-radio-${CONDITION_RADIOS[condition]}`,
    );
    await radio.click();
    await __.pause(page);
  },

  /**
   * Format a price the way the French form expects it
   * @param {number} price - Price in euros
   * @returns {string} Price with a decimal comma
   */
  formatPrice(price) {
    return String(price).replace('.', ',');
  },

  writeClipboard,
};
