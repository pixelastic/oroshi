import { firostError } from 'firost';

/**
 * Check that a threadId is given
 * @param {string} threadId - Id of the Thread, as printed by the other thread commands
 * @returns {void} Throws GMAIL_THREAD_ID_MISSING if empty
 */
export function requireThreadId(threadId) {
  if (!threadId) {
    throw firostError('GMAIL_THREAD_ID_MISSING', 'Pass the id of a Thread');
  }
}
