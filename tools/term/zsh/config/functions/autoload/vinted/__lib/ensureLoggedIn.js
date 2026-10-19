import { firostError } from 'firost';

// Vinted redirects visitors without a session to its /member/ pages
const LOGGED_OUT_PATH = '/member/';

/**
 * Throw an error when the page shows a logged-out Vinted session
 * Call it after opening a page that needs a session.
 * @param {object} page - Playwright page
 */
export async function ensureLoggedIn(page) {
  const { pathname } = new URL(page.url());
  if (!pathname.startsWith(LOGGED_OUT_PATH)) {
    return;
  }
  throw firostError(
    'VINTED_NOT_LOGGED_IN',
    'Vinted session expired, run vinted-login to log in again',
  );
}
