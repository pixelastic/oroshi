import { firostError } from 'firost';

const LOCATOR_TIMEOUT_IN_MS = 10000;

/**
 * Wait for a locator, or fail loudly with a given message
 * @param {object} locator - Playwright locator
 * @param {string} message - Error message when the locator never shows up
 * @param {string} state - Playwright state to wait for
 * @returns {Promise<object>} The first matching locator
 */
export async function waitForLocator(locator, message, state = 'visible') {
  const first = locator.first();
  try {
    await first.waitFor({ state, timeout: LOCATOR_TIMEOUT_IN_MS });
  } catch {
    throw firostError('VINTED_FORM_FIELD_MISSING', message);
  }
  return first;
}
