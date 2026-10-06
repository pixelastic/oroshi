import { PATCHED_KEY, SUGGESTION_HANDLER_REGEXP } from './suggestionHandler.js';

/**
 * Check if Down already accepts the Claude Code prompt suggestion
 * @param {string} text - Binary content, as a latin1 string
 * @returns {boolean} True when the handler carries the patched key name
 */
export function isSuggestionKeyPatched(text) {
  return text.match(SUGGESTION_HANDLER_REGEXP)?.[2] === PATCHED_KEY;
}
