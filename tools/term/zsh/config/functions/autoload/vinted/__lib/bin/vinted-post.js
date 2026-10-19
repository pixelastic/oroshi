// vinted-post.js
import os from 'node:os';
import path from 'node:path';
import { dayjs } from 'golgoth';
import { consoleSuccess } from 'firost';
import { ensureLoggedIn } from '../ensureLoggedIn.js';
import { fillListingForm } from '../fillListingForm.js';
import { openSession } from '../openSession.js';
import { parseListing } from '../parseListing.js';

const FORM_URL = 'https://www.vinted.fr/items/new';
const SCREENSHOT_DIRECTORY = path.join(
  os.homedir(),
  '.local/share/vinted-poster/screenshots',
);

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const listingPath = args.find((arg) => !arg.startsWith('--'));

// Parse first, so an invalid listing fails before any browser opens
const listing = await parseListing(listingPath);

const context = await openSession();
try {
  const page = context.pages()[0] ?? (await context.newPage());
  await page.goto(FORM_URL);
  await ensureLoggedIn(page);
  await fillListingForm(page, listing, dryRun);

  const screenshotPath = path.join(
    SCREENSHOT_DIRECTORY,
    `${dayjs().format('YYYY-MM-DD-HHmmss')}.png`,
  );
  await page.screenshot({ path: screenshotPath, fullPage: true });
  consoleSuccess(`Screenshot saved to ${screenshotPath}`);
} finally {
  await context.close();
}
