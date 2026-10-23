import { execFile } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { promisify } from 'node:util';
import { mkdirp, remove, tmpDirectory } from 'firost';

const run = promisify(execFile);

const RESOLUTION_IN_DPI = 50;
const POINTS_PER_INCH = 72;
const INK_THRESHOLD = 245;
const PADDING_IN_POINTS = 4;

/**
 * Read a binary PGM (P5) image
 * @param {Buffer} buffer - File content
 * @returns {object} { width, height, pixels }
 */
function readPgm(buffer) {
  // The header is three whitespace-separated tokens after the magic number
  let offset = 0;
  const tokens = [];
  while (tokens.length < 4) {
    while (/\s/.test(String.fromCharCode(buffer[offset]))) {
      offset++;
    }
    const start = offset;
    while (!/\s/.test(String.fromCharCode(buffer[offset]))) {
      offset++;
    }
    tokens.push(buffer.toString('ascii', start, offset));
  }
  // One whitespace byte separates the header from the pixels
  return {
    width: Number(tokens[1]),
    height: Number(tokens[2]),
    pixels: buffer.subarray(offset + 1),
  };
}

/**
 * Measure the printed area of the first page of a label
 * Labels are A4 pages with the label in one corner and the rest blank. The
 * page is rendered, and the box is the smallest one holding every non-white
 * pixel.
 * @param {string} labelPath - Path of the label PDF
 * @returns {Promise<object>} { left, bottom, right, top } in points, from the
 * bottom-left corner of the page
 */
export async function measureLabel(labelPath) {
  const directory = tmpDirectory('vinted/measureLabel');
  await mkdirp(directory);
  try {
    const prefix = path.join(directory, 'page');
    await run('pdftoppm', [
      '-gray',
      '-singlefile',
      '-f',
      '1',
      '-l',
      '1',
      '-r',
      String(RESOLUTION_IN_DPI),
      labelPath,
      prefix,
    ]);
    const { width, height, pixels } = readPgm(await readFile(`${prefix}.pgm`));

    let minX = width;
    let maxX = -1;
    let minY = height;
    let maxY = -1;
    pixels.forEach((value, index) => {
      if (value >= INK_THRESHOLD) {
        return;
      }
      const x = index % width;
      const y = Math.floor(index / width);
      minX = Math.min(minX, x);
      maxX = Math.max(maxX, x);
      minY = Math.min(minY, y);
      maxY = Math.max(maxY, y);
    });

    const scale = POINTS_PER_INCH / RESOLUTION_IN_DPI;
    const pageWidth = width * scale;
    const pageHeight = height * scale;
    // A blank page keeps the whole page
    if (maxX < 0) {
      return { left: 0, bottom: 0, right: pageWidth, top: pageHeight };
    }
    return {
      left: Math.max(0, minX * scale - PADDING_IN_POINTS),
      right: Math.min(pageWidth, (maxX + 1) * scale + PADDING_IN_POINTS),
      top: Math.min(pageHeight, pageHeight - minY * scale + PADDING_IN_POINTS),
      bottom: Math.max(0, pageHeight - (maxY + 1) * scale - PADDING_IN_POINTS),
    };
  } finally {
    await remove(directory);
  }
}
