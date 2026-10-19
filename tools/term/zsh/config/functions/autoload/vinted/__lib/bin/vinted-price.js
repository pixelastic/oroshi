// vinted-price.js
import { pMap } from 'golgoth';
import { consoleInfo } from 'firost';
import { mergeListings } from '../mergeListings.js';
import { openSession } from '../openSession.js';
import { searchPrices } from '../searchPrices.js';
import { summarizePrices } from '../summarizePrices.js';

const keywordsList = process.argv.slice(2);

const context = await openSession();
try {
  const page = context.pages()[0] ?? (await context.newPage());

  // One search at a time, so the requests stay paced
  const searches = await pMap(
    keywordsList,
    (keywords) => searchPrices(page, keywords),
    { concurrency: 1 },
  );

  const listings = mergeListings(searches);
  const summary = summarizePrices(listings.map((listing) => listing.price));
  const format = (price) => `${price.toFixed(2)} €`;

  consoleInfo(`Median asking price: ${format(summary.median)}`);
  consoleInfo(`Based on ${summary.count} listings`);
  consoleInfo(
    `Range: ${format(summary.min)} - ${format(summary.max)} (quartiles ${format(summary.firstQuartile)} - ${format(summary.thirdQuartile)})`,
  );
  consoleInfo('These are asking prices, not sale prices');
} finally {
  await context.close();
}
