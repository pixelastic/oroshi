import { suggestionPatch } from '../suggestion/src/suggestionPatch.js';
import { syntaxPatch } from '../syntax/src/syntaxPatch.js';

// Maps a patch name to its contract:
// - isPatched(text): true when the text already carries the patch
// - patch(text, options): returns { text, offsets }, with the exact input length
export const patches = {
  suggestion: suggestionPatch,
  syntax: syntaxPatch,
};
