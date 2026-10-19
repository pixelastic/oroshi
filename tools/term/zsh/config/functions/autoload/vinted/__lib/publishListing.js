import os from 'node:os';
import path from 'node:path';
import { dayjs } from 'golgoth';
import { firostError } from 'firost';
import { findField } from './findField.js';
import { savePage } from './savePage.js';

export let __;

const CONFIRMATION_TIMEOUT_IN_MS = 30000;
const LISTING_PATH_PATTERN = /^\/items\/\d+/;
const FORM_PATH = '/items/new';
const LOGIN_PATH_PATTERN = /^\/member\/(register|login)/;
const UPLOAD_PATH_PATTERN = /\/item_upload\/items/;
const ITEM_BASE_URL = 'https://www.vinted.fr/items';
const PAGES_DIRECTORY = path.join(
  os.homedir(),
  '.local/share/vinted-poster/pages',
);

/**
 * Publish the filled listing form and wait for Vinted to confirm it
 * Clicks the publish button once. Never retries, so a failed confirmation
 * cannot create a duplicate listing. The confirmation is the first of the
 * upload response (which carries the listing) or the page leaving the form.
 * @param {object} page - Playwright page showing the filled listing form
 * @param {object} listing - Listing being published, found again by its title
 * @returns {Promise<object>} URL of the published listing, and path of the
 * HTML page saved once the publication was confirmed, as { url, pagePath }
 */
export async function publishListing(page, listing) {
  const publishButton = await findField(page, 'upload-form-save-button');

  // Remember every POST, to help understand an unconfirmed publication
  const postedUrls = [];
  page.on('response', (response) => {
    if (response.request().method() === 'POST') {
      postedUrls.push(response.url());
    }
  });

  // Listen before clicking, the response can come right away
  const timeout = CONFIRMATION_TIMEOUT_IN_MS;
  const confirmation = Promise.any([
    (async () =>
      __.urlFromResponse(
        await page.waitForResponse(
          (response) => __.isUploadResponse(response),
          {
            timeout,
          },
        ),
      ))(),
    (async () => {
      await page.waitForURL((url) => __.hasLeftForm(url.href), { timeout });
      return null;
    })(),
  ]);
  await publishButton.click();

  let listingUrl;
  try {
    listingUrl = await confirmation;
  } catch {
    throw firostError(
      'VINTED_PUBLISH_NOT_CONFIRMED',
      `Publication not confirmed, check your Vinted account before running again. Page is at ${page.url()}. POST requests seen: ${postedUrls.join(', ') || 'none'}`,
    );
  }
  // Keep the page Vinted lands on, to learn where the listing link lives
  const pagePath = await __.savePage(
    page,
    PAGES_DIRECTORY,
    `published-${dayjs().format('YYYY-MM-DD-HHmmss')}`,
  );

  if (listingUrl && __.isListingUrl(listingUrl)) {
    return { url: listingUrl, pagePath };
  }
  // Vinted may land on the wardrobe, where the new listing is the one to find
  const url = (await __.findListingUrl(page, listing.title)) ?? page.url();
  return { url, pagePath };
}

__ = {
  /**
   * Find the URL of a listing on the current page, from its title
   * @param {object} page - Playwright page listing items, like the wardrobe
   * @param {string} title - Title of the listing
   * @returns {Promise<string|null>} Listing URL, or null when not found
   */
  async findListingUrl(page, title) {
    const links = page.locator('a[href*="/items/"]');
    try {
      await links.first().waitFor({ timeout: CONFIRMATION_TIMEOUT_IN_MS });
    } catch {
      return null;
    }
    const cards = await links.evaluateAll((elements) =>
      elements.map((element) => ({
        href: element.getAttribute('href'),
        title: element.getAttribute('title') ?? '',
      })),
    );
    const card = cards.find((item) => item.title.startsWith(title));
    if (!card) {
      return null;
    }
    const url = new URL(card.href, ITEM_BASE_URL);
    return `${url.origin}${url.pathname}`;
  },

  /**
   * Check if a URL is the page of a published listing
   * @param {string} url - Page URL
   * @returns {boolean} True for a /items/<id> page, false for /items/new
   */
  isListingUrl(url) {
    return LISTING_PATH_PATTERN.test(new URL(url).pathname);
  },

  /**
   * Check if a URL shows that the page moved on from the listing form
   * @param {string} url - Page URL
   * @returns {boolean} False for the form itself and for the login pages
   */
  hasLeftForm(url) {
    const { pathname } = new URL(url);
    return pathname !== FORM_PATH && !LOGIN_PATH_PATTERN.test(pathname);
  },

  /**
   * Check if a response is the successful answer to the listing upload
   * @param {object} response - Playwright response
   * @returns {boolean} True for a successful POST on the upload endpoint
   */
  isUploadResponse(response) {
    return (
      response.request().method() === 'POST' &&
      UPLOAD_PATH_PATTERN.test(response.url()) &&
      response.ok()
    );
  },

  /**
   * Read the URL of the new listing in the upload response
   * @param {object} response - Playwright response of the upload
   * @returns {Promise<string|null>} Listing URL, or null when it has none
   */
  async urlFromResponse(response) {
    let body = null;
    try {
      body = await response.json();
    } catch {
      return null;
    }
    const item = body?.item;
    if (item?.url) {
      return item.url;
    }
    return item?.id ? `${ITEM_BASE_URL}/${item.id}` : null;
  },

  savePage,
};
