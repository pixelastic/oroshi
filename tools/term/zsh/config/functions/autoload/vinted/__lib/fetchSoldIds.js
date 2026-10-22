import { firostError } from 'firost';
import { ensureLoggedIn } from './ensureLoggedIn.js';
import { parseSoldIds } from './parseSoldIds.js';

const SALES_URL = 'https://www.vinted.fr/my_orders/sold';
const LOGIN_BUTTON_SELECTOR = '[data-testid="header--login-button"]';

/**
 * Read the ids of the sold items from the seller's sales page
 * @param {object} page - Playwright page, logged in
 * @returns {Promise<string[]>} Unique item ids
 */
export async function fetchSoldIds(page) {
  await page.goto(SALES_URL);
  await page.waitForLoadState('networkidle');
  await ensureLoggedIn(page);

  // A logged-out visitor is sent to the home page, which shows a login button
  if ((await page.locator(LOGIN_BUTTON_SELECTOR).count()) > 0) {
    throw firostError(
      'VINTED_NOT_LOGGED_IN',
      'Vinted session expired, run vinted-login to log in again',
    );
  }
  return parseSoldIds(await page.content());
}
