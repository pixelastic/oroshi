import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatMail } from './formatMail.js';

export let __;

/**
 * Read a Message (a Gmail conversation) as a whole
 * @param {object} options - Read options
 * @param {string} options.messageId - Id of the Message. Throws GMAIL_MESSAGE_ID_MISSING if empty
 * @returns {Promise<object[]>} The Mails, formatted, oldest first
 */
export async function messageRead(options) {
  const { messageId } = options;

  if (!messageId) {
    throw firostError('GMAIL_MESSAGE_ID_MISSING', 'Pass the id of a Message');
  }

  const response = await __.callApi(`threads/${messageId}`, {
    query: { format: 'full' },
  });

  return _.chain(response.messages)
    .sortBy((mail) => Number(mail.internalDate))
    .map(__.formatMail)
    .value();
}

__ = {
  callApi,
  formatMail,
};
