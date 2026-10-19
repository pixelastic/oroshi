import os from 'node:os';
import path from 'node:path';
import { dayjs } from 'golgoth';
import { consoleInfo, consoleSuccess } from 'firost';
import { ensureLoggedIn } from '../ensureLoggedIn.js';
import { fillListingForm } from '../fillListingForm.js';
import { openSession } from '../openSession.js';
import { parseListingUpdate } from '../parseListingUpdate.js';
import { publishListing } from '../publishListing.js';
import { resolveEditUrl } from '../resolveEditUrl.js';

const SCREENSHOT_DIRECTORY = path.join(
  os.homedir(),
  '.local/share/vinted-poster/screenshots',
);

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const [idOrUrl, updatePath] = args.filter((arg) => !arg.startsWith('--'));

// Parse first, so an invalid update fails before any browser opens
const editUrl = resolveEditUrl(idOrUrl);
const update = await parseListingUpdate(updatePath);

let published = null;
const context = await openSession();
try {
  const page = context.pages()[0] ?? (await context.newPage());
  await page.goto(editUrl);
  await ensureLoggedIn(page);
  const timings = await fillListingForm(page, update);
  timings.forEach(({ step, durationInMs }) => {
    consoleInfo(`${step}: ${durationInMs}ms`);
  });

  const screenshotPath = path.join(
    SCREENSHOT_DIRECTORY,
    `${dayjs().format('YYYY-MM-DD-HHmmss')}.png`,
  );
  await page.screenshot({ path: screenshotPath, fullPage: true });
  consoleSuccess(`Screenshot saved to ${screenshotPath}`);

  if (!dryRun) {
    published = await publishListing(page, update);
    consoleSuccess(`Listing updated: ${published.url}`);
  }
} finally {
  await context.close();
}

// Last line of the output, for the callers that need to read it
if (published) {
  console.log(JSON.stringify({ url: published.url }));
}
