import { text } from 'node:stream/consumers';
import { consoleError, exit } from 'firost';
import { organizePhotos } from '../photoFolder/index.js';

const folder = process.argv[2];

try {
  const groups = JSON.parse(await text(process.stdin));
  const folders = await organizePhotos(folder, groups);
  process.stdout.write(`${JSON.stringify(folders, null, 2)}\n`);
} catch (error) {
  consoleError(error.message);
  exit(1);
}
