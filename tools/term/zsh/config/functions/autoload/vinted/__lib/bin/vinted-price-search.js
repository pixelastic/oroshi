import { _, pMap } from 'golgoth';
import { mergeListings } from '../mergeListings.js';
import { openSession } from '../openSession.js';
import { searchPrices } from '../searchPrices.js';

const PAUSE_RANGE_IN_MS = [1000, 3000];

const keywordsList = process.argv.slice(2);

const context = await openSession();
try {
  const page = context.pages()[0] ?? (await context.newPage());

  // One search at a time, with a human-like pause before each
  const searches = await pMap(
    keywordsList,
    async (keywords) => {
      await page.waitForTimeout(_.random(...PAUSE_RANGE_IN_MS));
      return searchPrices(page, keywords);
    },
    { concurrency: 1 },
  );

  const listings = mergeListings(searches);

  process.stdout.write(`${JSON.stringify(listings, null, 2)}\n`);
} finally {
  await context.close();
}
