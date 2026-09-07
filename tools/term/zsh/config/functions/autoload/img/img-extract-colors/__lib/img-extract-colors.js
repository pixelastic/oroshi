import { _ } from 'golgoth';
import { consoleError } from 'firost';
import { Vibrant } from 'node-vibrant/node';

const swatchKeys = [
  'Vibrant',
  'DarkVibrant',
  'LightVibrant',
  'Muted',
  'DarkMuted',
  'LightMuted',
];

const imagePath = process.argv[2];
if (!imagePath) {
  consoleError('Usage: img-extract-colors <image-path>');
  process.exit(1);
}

// getPalette() returns rich swatch objects: { Vibrant: { rgb, hex, population }, ... }
// We flatten to { Vibrant: "#hex", DarkVibrant: null, ... }
const palette = await Vibrant.from(imagePath).getPalette();
const colors = _.chain(swatchKeys)
  .keyBy()
  .mapValues((key) => palette[key]?.hex ?? null)
  .value();

console.log(JSON.stringify(colors));
