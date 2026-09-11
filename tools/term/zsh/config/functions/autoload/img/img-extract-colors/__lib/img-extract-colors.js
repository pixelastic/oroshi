import { consoleError } from 'firost';
import { semanticPalette } from 'imoen';

const imagePath = process.argv[2];
if (!imagePath) {
  consoleError('Usage: img-extract-colors <image-path>');
  process.exit(1);
}

const colors = await semanticPalette(imagePath);
if (!colors) {
  consoleError(`Could not extract colors from ${imagePath}`);
  process.exit(1);
}

console.log(JSON.stringify(colors));
