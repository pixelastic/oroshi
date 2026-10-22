import { _ } from 'golgoth';
import { consoleError, consoleInfo, consoleSuccess, exit } from 'firost';
import { fetchSoldIds } from '../fetchSoldIds.js';
import { listStaleListings, syncSales } from '../listingFolder/index.js';
import { openSession } from '../openSession.js';

const [root, olderThan] = process.argv.slice(2);

try {
  if (olderThan === undefined) {
    // Mark the listings found on the sales page as sold
    const context = await openSession();
    try {
      const page = context.pages()[0] ?? (await context.newPage());
      const marked = await syncSales(root, await fetchSoldIds(page));
      consoleSuccess(`${marked.length} listing(s) marked as sold`);
      _.each(marked, (folder) => console.log(folder));
    } finally {
      await context.close();
    }
  } else {
    // List the listings online for more than the given number of days
    const days = _.toNumber(olderThan);
    const stale = await listStaleListings(root, { days });
    if (_.isEmpty(stale)) {
      consoleInfo(`No listing online for more than ${days} days`);
    }
    _.each(stale, ({ ageInDays, title, url }) =>
      console.log(`${ageInDays} days  ${title}  ${url}`),
    );
  }
} catch (error) {
  consoleError(error.message);
  exit(1);
}
