import { isSuggestionKeyPatched } from './isSuggestionKeyPatched.js';
import { patchSuggestionKey } from './patchSuggestionKey.js';

/**
 * Patch contract of the prompt suggestion key (Down accepts the suggestion)
 */
export const suggestionPatch = {
  isPatched: isSuggestionKeyPatched,
  /**
   * @param {string} text - Binary content, as a latin1 string
   * @returns {{text: string, offsets: number[]}} Patched text and patched offsets
   */
  patch(text) {
    if (isSuggestionKeyPatched(text)) {
      return { text, offsets: [] };
    }
    const { text: patchedText, offset } = patchSuggestionKey(text);
    return { text: patchedText, offsets: [offset] };
  },
};
