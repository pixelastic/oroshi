import { consoleError, exit } from 'firost';
import { formatRecap, recapListings } from '../listingFolder/index.js';

try {
  const recap = await recapListings(process.argv[2]);
  console.log(formatRecap(recap));
} catch (error) {
  consoleError(error.message);
  exit(1);
}
