import { consoleError, consoleSuccess, exit } from 'firost';
import { publishListings } from '../listingFolder/index.js';

try {
  const published = await publishListings(process.argv[2]);
  consoleSuccess(`${published.length} listing(s) published`);
} catch (error) {
  consoleError(error.message);
  exit(1);
}
