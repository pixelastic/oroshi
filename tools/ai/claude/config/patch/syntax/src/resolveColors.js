import { _ } from 'golgoth';
import { firostError } from 'firost';

/**
 * Resolve color names from colors.json to their hex value
 * @param {object} colorNames - Map of key → color name
 * @param {object} colors - Content of colors.json
 * @returns {object} Map of key → '#rrggbb'
 */
export function resolveColors(colorNames, colors) {
  return _.mapValues(colorNames, (colorName, key) => {
    const hex = colors[colorName]?.hex;
    if (!hex) {
      throw firostError(
        'CLAUDE_SYNTAX_PATCH_UNKNOWN_COLOR',
        `Unknown color "${colorName}" for "${key}"`,
      );
    }
    return hex;
  });
}
