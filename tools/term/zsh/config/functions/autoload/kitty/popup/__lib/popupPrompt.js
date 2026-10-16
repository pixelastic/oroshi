import { prompt } from 'firost';

export let __;

/**
 * Ask one question in a popup
 * @param {string} message - Label of the question
 * @returns {Promise<string|null>} The trimmed answer, or null if the user pressed Ctrl-C
 */
export async function popupPrompt(message) {
  try {
    const answer = await __.prompt(message);
    return answer.trim();
  } catch (err) {
    // Ctrl-C cancels the popup
    if (err.code === 'FIROST_PROMPT_CTRL_C') {
      return null;
    }
    throw err;
  }
}

__ = {
  prompt,
};
