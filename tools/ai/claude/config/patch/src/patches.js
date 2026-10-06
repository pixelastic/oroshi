import { suggestionPatch } from '../suggestion/src/suggestionPatch.js';

// Maps a patch name to its contract:
// - isPatched(text): true when the text already carries the patch
// - patch(text): returns { text, offsets }, with the exact input length
export const patches = {
  suggestion: suggestionPatch,
};
