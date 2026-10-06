import { firostError } from 'firost';
import {
  ORIGINAL_KEY,
  PATCHED_KEY,
  SUGGESTION_HANDLER_REGEXP,
} from './suggestionHandler.js';

/**
 * Make Down, instead of Right, accept the Claude Code prompt suggestion.
 * The output has the exact same length as the input, so it can be written
 * back into the binary without moving any offset.
 * An already patched text is returned unchanged, with the same offset.
 * @param {string} text - Binary content, as a latin1 string
 * @returns {{text: string, offset: number}} Patched text and offset of the patched key name
 * @throws {Error} CLAUDE_SUGGESTION_PATCH_HANDLER_NOT_FOUND when the handler is missing
 */
export function patchSuggestionKey(text) {
  const match = text.match(SUGGESTION_HANDLER_REGEXP);
  if (!match) {
    throw firostError(
      'CLAUDE_SUGGESTION_PATCH_HANDLER_NOT_FOUND',
      'Could not find the prompt suggestion key handler',
    );
  }

  const [offset] = match.indices[2];
  if (match[2] === PATCHED_KEY) {
    return { text, offset };
  }

  const patchedText =
    text.slice(0, offset) +
    PATCHED_KEY +
    text.slice(offset + ORIGINAL_KEY.length);
  return { text: patchedText, offset };
}
