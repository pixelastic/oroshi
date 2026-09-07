import path from 'node:path';
import { _ } from 'golgoth';
import { run } from 'firost';

const testDirectory = import.meta.dirname;
const scriptPath = path.resolve(
  testDirectory,
  '../__lib/img-extract-colors.js',
);
const fixturesPath = path.resolve(testDirectory, 'fixtures');

/**
 * @param {string} fixture - Fixture filename
 * @returns {object} Parsed JSON output from the script
 */
async function runScript(fixture) {
  const result = await run(['node', scriptPath, `${fixturesPath}/${fixture}`], {
    stdout: false,
  });
  return JSON.parse(result.stdout);
}

describe('img-extract-colors', () => {
  it('returns all 6 swatch keys', async () => {
    const actual = await runScript('colorful.png');

    expect(_.keys(actual)).toEqual([
      'Vibrant',
      'DarkVibrant',
      'LightVibrant',
      'Muted',
      'DarkMuted',
      'LightMuted',
    ]);
  });

  it('returns hex strings for present swatches', async () => {
    const actual = await runScript('colorful.png');

    const hexPattern = /^#[0-9a-f]{6}$/i;
    const presentSwatches = _.chain(actual).values().compact().value();
    _.each(presentSwatches, (value) => {
      expect(value).toMatch(hexPattern);
    });
  });

  it('returns null for swatches that node-vibrant cannot extract', async () => {
    const actual = await runScript('gray.png');

    expect(actual).toHaveProperty('Vibrant', null);
  });
});
