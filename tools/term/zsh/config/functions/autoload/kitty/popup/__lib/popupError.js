import { consoleError } from 'firost';
import { popupPrompt } from './popupPrompt.js';

/**
 * Keep an error visible in a popup until the user presses Enter
 * @param {string} message - Error to display
 */
export async function popupError(message) {
  consoleError(message);
  await popupPrompt('Press Enter to close');
}
