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
  it('returns exactly 4 semantic keys', async () => {
    const actual = await runScript('colorful.png');

    expect(_.chain(actual).keys().sort().value()).toEqual([
      'accent',
      'background',
      'muted',
      'text',
    ]);
  });

  it('returns hex strings or null for each key', async () => {
    const actual = await runScript('colorful.png');

    const hexOrNull = /^(#[0-9a-f]{6}|null)$/i;
    _.each(['background', 'text', 'accent', 'muted'], (key) => {
      expect(String(actual[key])).toMatch(hexOrNull);
    });
  });

  it('returns null for roles that cannot be extracted', async () => {
    const actual = await runScript('gray.png');

    const values = _.values(actual);
    expect(values).toContain(null);
  });
});
