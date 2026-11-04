import { consoleError, read, write } from 'firost';
import { getTheme } from './getTheme.js';
import { renderMermaid } from './renderMermaid.js';

const [inputPath, outputPath] = process.argv.slice(2);
if (!inputPath || !outputPath) {
  consoleError('Usage: mmd2svg.js <input.mmd> <output.svg>');
  process.exit(1);
}

try {
  const svg = renderMermaid(await read(inputPath), await getTheme());
  await write(svg, outputPath);
} catch (error) {
  consoleError(`✘ ${inputPath}: ${error.message}`);
  process.exit(1);
}
