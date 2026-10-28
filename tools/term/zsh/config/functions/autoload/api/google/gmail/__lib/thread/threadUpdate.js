import { _ } from 'golgoth';
import { callApi } from '../callApi.js';

export let __;

/**
 * Update the state of a Thread
 * @param {object} options - Update options
 * @param {string} options.threadId - Id of the Thread, as printed by the other thread commands
 * @param {boolean} [options.read] - Mark every Message of the Thread as read
 * @param {boolean} [options.unread] - Mark the Thread as unread
 * @returns {Promise<object>} The state of the Thread, as { threadId, unread }
 */
export async function threadUpdate(options) {
  const { threadId, read, unread } = options;

  const labelChange = unread
    ? { addLabelIds: ['UNREAD'] }
    : { removeLabelIds: ['UNREAD'] };
  const response = await __.callApi(`threads/${threadId}/modify`, {
    method: 'POST',
    body: labelChange,
  });

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

  callApi,
};
