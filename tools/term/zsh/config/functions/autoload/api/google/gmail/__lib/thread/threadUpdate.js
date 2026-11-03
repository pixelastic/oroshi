import { _ } from 'golgoth';
import { firostError } from 'firost';
import { modifyLabels } from './modifyLabels.js';
import { requireThreadId } from './requireThreadId.js';

export let __;

/**
 * Update the state of a Thread
 * @param {object} options - Update options
 * @param {string} options.threadId - Id of the Thread, as printed by the other thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @param {boolean} [options.read] - Mark every Message of the Thread as read
 * @param {boolean} [options.unread] - Mark the Thread as unread. Throws GMAIL_THREAD_UPDATE_EMPTY if neither read nor unread is set, and GMAIL_THREAD_UPDATE_CONFLICT if both are
 * @returns {Promise<object>} The state of the Thread, as { threadId, unread }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function threadUpdate(options) {
  const { threadId, read, unread } = options;

  requireThreadId(threadId);
  if (!read && !unread) {
    throw firostError('GMAIL_THREAD_UPDATE_EMPTY', 'Pass --read or --unread');
  }
  if (read && unread) {
    throw firostError(
      'GMAIL_THREAD_UPDATE_CONFLICT',
      'Pass --read or --unread, not both',
    );
  }

  const labelChange = unread ? { add: ['UNREAD'] } : { remove: ['UNREAD'] };
  const response = await __.modifyLabels({ threadId, ...labelChange });

  return { threadId, unread: __.isUnread(response, !read) };
}

__ = {
  /**
   * Check if a Message of the response is still unread
   * @param {object} response - The Thread, as returned by the Gmail API
   * @param {boolean} fallback - Value to use when the response has no labelIds
   * @returns {boolean} True if one Message carries the UNREAD label
   */
  isUnread(response, fallback) {
    const hasLabels = _.some(response?.messages, 'labelIds');
    if (!hasLabels) {
      return fallback;
    }
    return _.some(response.messages, (message) =>
      _.includes(message.labelIds, 'UNREAD'),
    );
  },

  modifyLabels,
};
