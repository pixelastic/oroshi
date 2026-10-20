import { text } from 'node:stream/consumers';
import { consoleError, exit } from 'firost';
import { computeListingPrice } from '../computeListingPrice.js';

const BASES = ['isbn', 'title', 'few'];

const args = process.argv.slice(2);
const basis = args[args.indexOf('--basis') + 1];

// The basis must be known, to report where the price comes from
if (!BASES.includes(basis)) {
  consoleError(`--basis must be one of: ${BASES.join(', ')}`);
  exit(1);
}

const rows = JSON.parse(await text(process.stdin));

try {
  const result = computeListingPrice(rows, { basis });
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
} catch (error) {
  consoleError(error.message);
  exit(1);
}
