import { run } from 'firost';
import { popupError } from './popupError.js';
import { popupPrompt } from './popupPrompt.js';

export let __;

/**
 * Ask for a misheard word and its replacement, and add them to the mic2txt autocorrect rules
 * An empty replacement suppresses the word
 * Nothing is added if the user cancels or leaves the misheard word empty
 * @returns {Promise<boolean>} True if the rule was added, false otherwise
 */
export async function popupAutocorrect() {
  const wrong = await __.popupPrompt('Misheard word:');

  // Cancelled or nothing to correct
  if (!wrong) {
    return false;
  }

  const right = await __.popupPrompt('Replacement:');

  // Cancelled
  if (right === null) {
    return false;
  }

  try {
    await __.run(['bin-zsh', 'mic2txt-autocorrect-add', wrong, right]);
    return true;
  } catch {
    await __.popupError(`Could not add autocorrect rule: ${wrong} → ${right}`);
    return false;
  }
}

__ = {
  run,
  popupError,
  popupPrompt,
};
