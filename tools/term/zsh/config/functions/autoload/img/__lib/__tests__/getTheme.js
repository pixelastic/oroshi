import path from 'node:path';
import { _ } from 'golgoth';
import { remove, tmpDirectory, writeJson } from 'firost';
import { getTheme } from '../getTheme.js';

describe('getTheme', () => {
  let testDirectory;
  let colorsPath;
  beforeEach(async () => {
    testDirectory = tmpDirectory('getTheme');
    colorsPath = path.join(testDirectory, 'colors.json');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  /**
   * Write a colors.json fixture, one entry per key
   * @param {object} hexByKey - Hex value of each palette key
   */
  async function writeColors(hexByKey) {
    const colors = _.mapValues(hexByKey, (hex) => ({ ansi: 1, hex }));
    await writeJson(colors, colorsPath);
  }

  const palette = {
    terminal: '#0c0f15',
    'selected-background': '#1f2937',
    text: '#d1d5db',
    info: '#3182ce',
    comment: '#6b7280',
    'gray-4': '#9ca3af',
    unrelated: '#ff0000',
  };

  it('returns the theme mapped from the palette', async () => {
    await writeColors(palette);

    const actual = await getTheme(colorsPath);

    const expected = {
      background: '#0c0f15',
      foreground: '#d1d5db',
      accent: '#3182ce',
      line: '#6b7280',
      muted: '#9ca3af',
    };
    expect(actual).toEqual(expected);
  });

  it('returns hex strings in the #rrggbb form', async () => {
    await writeColors(palette);

    const actual = await getTheme(colorsPath);

    _.each(actual, (value) => {
      expect(value).toMatch(/^#[0-9a-f]{6}$/);
    });
  });

  it('reads the built colors.json by default', async () => {
    const actual = await getTheme();

    expect(_.chain(actual).keys().sort().value()).toEqual([
      'accent',
      'background',
      'foreground',
      'line',
      'muted',
    ]);
  });

  it('throws a message mentioning colors-build when the file is missing', async () => {
    let actual = null;
    try {
      await getTheme(colorsPath);
    } catch (error) {
      actual = error;
    }

    const expected = `Cannot find ${colorsPath}. Run colors-build to create it.`;
    expect(actual).toHaveProperty('message', expected);
  });

  it.each([
    { input: 'terminal' },
    { input: 'text' },
    { input: 'info' },
    { input: 'comment' },
    { input: 'gray-4' },
  ])('throws a message naming the absent key $input', async ({ input }) => {
    const { [input]: _removed, ...incomplete } = palette;
    await writeColors(incomplete);

    let actual = null;
    try {
      await getTheme(colorsPath);
    } catch (error) {
      actual = error;
    }

    const expected = `Cannot find the "${input}" color in ${colorsPath}. Run colors-build to rebuild it.`;
    expect(actual).toHaveProperty('message', expected);
  });
});
