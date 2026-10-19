import { waitForLocator } from './waitForLocator.js';

/**
 * Find a form field by its test id, or fail loudly when it is missing
 * @param {object} page - Playwright page
 * @param {string} testId - data-testid of the field
 * @param {string} state - Playwright state to wait for
 * @returns {Promise<object>} Playwright locator of the field
 */
export function findField(page, testId, state) {
  return waitForLocator(
    page.getByTestId(testId),
    `Form field "${testId}" not found, the Vinted form may have changed`,
    state,
  );
}
