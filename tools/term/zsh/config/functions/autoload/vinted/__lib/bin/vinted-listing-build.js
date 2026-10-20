import { parseArgs } from 'node:util';
import { consoleError, exit } from 'firost';
import { buildListing } from '../listingFolder/index.js';

const CATEGORY_SEPARATOR = ' > ';

const { positionals, values } = parseArgs({
  allowPositionals: true,
  options: {
    series: { type: 'string' },
    number: { type: 'string' },
    publisher: { type: 'string' },
    isbn: { type: 'string' },
    price: { type: 'string' },
    category: { type: 'string' },
    uncertain: { type: 'boolean' },
  },
});

try {
  const filepath = await buildListing(positionals[0], {
    ...values,
    price: Number(values.price),
    category: values.category?.split(CATEGORY_SEPARATOR),
    isPriceUncertain: values.uncertain,
  });
  console.log(filepath);
} catch (error) {
  consoleError(error.message);
  exit(1);
}
