import { PATCH_MARKER, patchHighlightTables } from './patchHighlightTables.js';

/**
 * Patch contract of the syntax highlighting colors
 */
export const syntaxPatch = {
  /**
   * @param {string} text - Binary content, as a latin1 string
   * @returns {boolean} True when the text carries the patch marker
   */
  isPatched(text) {
    return text.includes(PATCH_MARKER);
  },
  /**
   * @param {string} text - Binary content, as a latin1 string
   * @param {object} options - Patch inputs
   * @param {object} options.scopeColors - Map of highlight.js scope → '#rrggbb'
   * @param {object} [options.decorationColors] - Diff line number and marker colors
   * @returns {{text: string, offsets: number[]}} Patched text and patched offsets
   */
  patch(text, { scopeColors, decorationColors }) {
    return patchHighlightTables(text, scopeColors, decorationColors);
  },
};
