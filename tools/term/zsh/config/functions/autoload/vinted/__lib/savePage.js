import path from 'node:path';
import { write } from 'firost';

const SETTLE_DELAY_IN_MS = 2000;

/**
 * Save the HTML and a screenshot of the current page, for offline analysis
 * Waits a little first, so a page that renders client-side is complete.
 * @param {object} page - Playwright page
 * @param {string} directory - Directory to write in
 * @param {string} name - File name, without extension
 * @returns {Promise<string>} Path of the HTML file
 */
export async function savePage(page, directory, name) {
  await page.waitForLoadState('domcontentloaded');
  await page.waitForTimeout(SETTLE_DELAY_IN_MS);

  const htmlPath = path.join(directory, `${name}.html`);
  await write(await page.content(), htmlPath);
  await page.screenshot({
    path: path.join(directory, `${name}.png`),
    fullPage: true,
  });
  return htmlPath;
}
