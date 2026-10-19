import { _, pMap } from 'golgoth';
import { firostError } from 'firost';

export let __;

const FIELD_TIMEOUT_IN_MS = 10000;
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
 * Fill the Vinted listing form, and publish it unless in dry-run mode
 * The page must already show the listing form of a logged-in session. Stops
 * with an error as soon as a form field is missing.
 * @param {object} page - Playwright page showing the listing form
 * @param {object} listing - Listing returned by parseListing
 * @param {boolean} dryRun - True to leave the form unpublished
 */
export async function fillListingForm(page, listing, dryRun) {
  await __.acceptCookies(page);

  await __.setPhotos(page, listing.photos);
  await __.typeIn(page, 'title--input', listing.title);
  await __.typeIn(page, 'description--input', listing.description);
  await __.pickCategory(page, listing.category);
  await __.typeIn(page, 'isbn--input', listing.isbn);
  await __.pickCondition(page, listing.condition);
  await __.typeIn(page, 'price-input--input', __.formatPrice(listing.price));

  if (dryRun) {
    return;
  }
  const publishButton = await __.field(page, 'upload-form-save-button');
  await publishButton.click();
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
   * Wait for a locator, or fail loudly with a given message
   * @param {object} locator - Playwright locator
   * @param {string} message - Error message when the locator never shows up
   * @param {string} state - Playwright state to wait for
   * @returns {Promise<object>} The first matching locator
   */
  async waitFor(locator, message, state = 'visible') {
    const first = locator.first();
    try {
      await first.waitFor({ state, timeout: FIELD_TIMEOUT_IN_MS });
    } catch {
      throw firostError('VINTED_FORM_FIELD_MISSING', message);
    }
    return first;
  },

  /**
   * Find a form field by its test id, or fail loudly when it is missing
   * @param {object} page - Playwright page
   * @param {string} testId - data-testid of the field
   * @param {string} state - Playwright state to wait for
   * @returns {Promise<object>} Playwright locator of the field
   */
  field(page, testId, state) {
    return __.waitFor(
      page.getByTestId(testId),
      `Form field "${testId}" not found, the Vinted form may have changed`,
      state,
    );
  },

  /**
   * Upload the photos
   * @param {object} page - Playwright page
   * @param {string[]} photos - Absolute photo paths
   */
  async setPhotos(page, photos) {
    // The file input is hidden, so it only needs to be attached
    const input = await __.field(page, 'add-photos-input', 'attached');
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
    const input = await __.field(page, testId);
    await input.click();
    await input.pressSequentially(text, { delay: TYPING_DELAY_IN_MS });
    await __.pause(page);
  },

  /**
   * Walk the category picker, one label per level
   * @param {object} page - Playwright page
   * @param {string[]} labels - Category labels, from the root to the leaf
   */
  async pickCategory(page, labels) {
    const picker = await __.field(page, 'catalog-select-dropdown-input');
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
    const list = await __.field(page, 'category-list');
    const item = await __.waitFor(
      list
        .locator('li')
        .filter({ has: page.getByText(label, { exact: true }) }),
      `Category "${label}" not found in the category picker`,
    );
    await item.click();
    await __.pause(page);
  },

  /**
   * Select the condition radio
   * @param {object} page - Playwright page
   * @param {string} condition - One of the five English condition labels
   */
  async pickCondition(page, condition) {
    const container = await __.field(
      page,
      'category-condition-single-list-input',
    );
    await container.click();
    await __.pause(page);

    const radio = await __.field(
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
};
