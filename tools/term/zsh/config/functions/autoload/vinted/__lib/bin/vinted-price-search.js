import { _, pMap } from 'golgoth';
import { consoleInfo } from 'firost';
import { formatPrice } from '../formatPrice.js';
import { mergeListings } from '../mergeListings.js';
import { openSession } from '../openSession.js';
import { searchPrices } from '../searchPrices.js';
import { summarizePrices } from '../summarizePrices.js';

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
  const summary = summarizePrices(listings.map((listing) => listing.price));

  consoleInfo(`Median asking price: ${formatPrice(summary.median)}`);
  consoleInfo(`Based on ${summary.count} listings`);
  consoleInfo(
    `Range: ${formatPrice(summary.min)} - ${formatPrice(summary.max)} (quartiles ${formatPrice(summary.firstQuartile)} - ${formatPrice(summary.thirdQuartile)})`,
  );
  consoleInfo('These are asking prices, not sale prices');
} finally {
  await context.close();
}
