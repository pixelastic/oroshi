import { runBin } from '@oroshi/api-shared/runBin.js';
import { gdocRead } from '../read.js';

await runBin(async () => {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdoc-read <url-or-doc-id>');
    process.exit(1);
  }

  const { markdown } = await gdocRead(input);
  process.stdout.write(markdown);
});
