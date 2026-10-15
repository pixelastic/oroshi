import { join } from 'node:path';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { __, gdoc2md } from '../toMarkdown.js';

await runBin(async () => {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdoc2md <url-or-doc-id>');
    process.exit(1);
  }

  const { markdown, images, slug } = await gdoc2md(input);
  const outputDirectory = join(process.cwd(), slug);
  await __.writeOutput(outputDirectory, markdown, images);
  console.log(outputDirectory);
});
