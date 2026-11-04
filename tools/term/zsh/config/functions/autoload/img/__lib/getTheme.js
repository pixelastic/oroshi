import path from 'node:path';
import { _ } from 'golgoth';
import { exists, readJson } from 'firost';

export let __;

// Theme value → colors.json key
const paletteKeys = {
  background: 'terminal',
  foreground: 'text',
  accent: 'info',
  line: 'comment',
  muted: 'gray-4',
};

/**
 * Build the diagram theme from the generated colors.json
 * @param {string} [colorsPath] - Path to colors.json, defaults to the built one
 * @returns {Promise<object>} Hex colors: background, foreground, accent, line, muted
 */
export async function getTheme(colorsPath = __.defaultColorsPath) {
  if (!(await exists(colorsPath))) {
    throw new Error(
      `Cannot find ${colorsPath}. Run colors-build to create it.`,
    );
  }

  const colors = await readJson(colorsPath);

  return _.mapValues(paletteKeys, (key) => {
    const hex = colors[key]?.hex;
    if (!hex) {
      throw new Error(
        `Cannot find the "${key}" color in ${colorsPath}. Run colors-build to rebuild it.`,
      );
    }
    return hex;
  });
}

__ = {
  defaultColorsPath: path.resolve(
    import.meta.dirname,
    '../../../../theming/dist/colors.json',
  ),
};
