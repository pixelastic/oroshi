import { run } from 'firost';
import { popupError } from './popupError.js';
import { popupPrompt } from './popupPrompt.js';

export let __;

/**
 * Ask for one command and add it to the Claude Code skills allowlist
 * Nothing is added if the user cancels or leaves the answer empty
 * @returns {Promise<boolean>} True if the command was added, false otherwise
 */
export async function popupSkala() {
  const command = await __.popupPrompt('Add to allowlist:');

  // Cancelled or nothing to add
  if (!command) {
    return false;
  }

  try {
    await __.run(['bin-zsh', 'skills-allowlist-add', command]);
    return true;
  } catch {
    await __.popupError(`Could not add to allowlist: ${command}`);
    return false;
  }
}

__ = {
  run,
  popupError,
  popupPrompt,
};
