import { text } from 'node:stream/consumers';
import { consoleError, exit } from 'firost';
import { mergeGroups } from '../photoFolder/index.js';

try {
  const batches = JSON.parse(await text(process.stdin));
  const groups = mergeGroups(batches);
  process.stdout.write(`${JSON.stringify(groups, null, 2)}\n`);
} catch (error) {
  consoleError(error.message);
  exit(1);
}
