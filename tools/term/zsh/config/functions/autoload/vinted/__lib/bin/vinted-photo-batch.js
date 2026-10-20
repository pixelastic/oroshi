import { consoleError, exit } from 'firost';
import { batchPhotos } from '../photoFolder/index.js';

const folder = process.argv[2];

try {
  const batches = await batchPhotos(folder);
  process.stdout.write(`${JSON.stringify(batches, null, 2)}\n`);
} catch (error) {
  consoleError(error.message);
  exit(1);
}
