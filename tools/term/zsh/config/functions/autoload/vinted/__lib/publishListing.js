import { firostError } from 'firost';
import { __ as form } from './fillListingForm.js';

export let __;

const CONFIRMATION_TIMEOUT_IN_MS = 30000;
const LISTING_PATH_PATTERN = /^\/items\/\d+/;

/**
 * Publish the filled listing form and wait for the listing page
 * Clicks the publish button once. Never retries, so a failed confirmation
 * cannot create a duplicate listing.
 * @param {object} page - Playwright page showing the filled listing form
 * @returns {Promise<string>} URL of the published listing
 */
export async function publishListing(page) {
  const publishButton = await form.field(page, 'upload-form-save-button');
  await publishButton.click();

  try {
    await page.waitForURL((url) => __.isListingUrl(url.href), {
      timeout: CONFIRMATION_TIMEOUT_IN_MS,
    });
  } catch {
    throw firostError(
      'VINTED_PUBLISH_NOT_CONFIRMED',
      `Publication not confirmed, check your Vinted account before running again. Page is at ${page.url()}`,
    );
  }
  return page.url();
}

__ = {
  /**
   * Check if a URL is the page of a published listing
   * @param {string} url - Page URL
   * @returns {boolean} True for a /items/<id> page, false for /items/new
   */
  isListingUrl(url) {
    return LISTING_PATH_PATTERN.test(new URL(url).pathname);
  },
};
