import os from 'node:os';
import path from 'node:path';
import { dayjs } from 'golgoth';
import { consoleError } from 'firost';
import { savePage } from './savePage.js';

export let __;

const PAGES_DIRECTORY = path.join(
  os.homedir(),
  '.local/share/vinted-poster/pages',
);

/**
 * Run an action on the page, and keep the page as it was if the action fails
 * Saves the HTML and a screenshot, so the cause of a failed form step can be
 * read afterwards. The original error is always rethrown.
 * @param {object} page - Playwright page
 * @param {Function} action - Async action to run
 * @returns {Promise<*>} What the action returns
 */
export async function snapshotOnFailure(page, action) {
  try {
    return await action();
  } catch (error) {
    await __.saveFailedPage(page);
    throw error;
  }
}

__ = {
  /**
   * Save the page after a failure, and tell where it went
   * A failure to save must not hide the original error.
   * @param {object} page - Playwright page
   */
  async saveFailedPage(page) {
    try {
      const pagePath = await __.savePage(
        page,
        PAGES_DIRECTORY,
        `failed-${dayjs().format('YYYY-MM-DD-HHmmss')}`,
      );
      __.consoleError(`Page saved after the failure: ${pagePath}`);
    } catch {
      // The browser may be gone, the original error matters more
    }
  },

  savePage,
  consoleError,
};
