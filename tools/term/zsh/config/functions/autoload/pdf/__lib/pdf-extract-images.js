import { basename, dirname } from 'node:path';
import { pMap } from 'golgoth';
import { absolute } from 'firost';
import { extractImages } from 'pietro';

const args = process.argv.slice(2);
const cwd = process.cwd();

if (args.length === 0) {
  console.error('Usage: pdf-extract-images <pdf-file> [<pdf-file> ...]');
  process.exit(1);
}

await pMap(args, async (arg) => {
  const filepath = absolute(cwd, arg);
  const pdfBasename = basename(filepath, '.pdf');
  const pdfDirname = dirname(filepath);
  const outputDir = absolute(pdfDirname, pdfBasename);
  console.log({ filepath, outputDir });

  console.log(`Extracting images from ${filepath}...`);
  await extractImages(filepath, outputDir);
  console.log(`✓ Images extracted to ${outputDir}/`);
});
