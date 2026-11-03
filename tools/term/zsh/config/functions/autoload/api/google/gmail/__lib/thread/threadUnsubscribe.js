import { _ } from 'golgoth';
import { firostError } from 'firost';
import { header } from '../header.js';
import { getThread } from './getThread.js';
import { requireThreadId } from './requireThreadId.js';

export let __;

/**
 * Unsubscribe from a mailing list, with the one-click POST of RFC 8058. The
 * action is irreversible: the sender removes the address from its list
 * @param {object} options - Unsubscribe options
 * @param {string} options.threadId - Id of the Thread, as printed by the other thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @returns {Promise<object>} The result, as { threadId, url, done }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist, and GMAIL_UNSUBSCRIBE_NOT_AVAILABLE if the last Message has no one-click HTTPS link or the POST fails
 */
export async function threadUnsubscribe(options) {
  const { threadId } = options;

  requireThreadId(threadId);
  const response = await __.getThread(threadId, {
    query: { format: 'metadata' },
  });
  const message = _.last(response.messages);
  const links = __.parseLinks(header(message, 'List-Unsubscribe'));
  const hasPostHeader = header(message, 'List-Unsubscribe-Post') !== '';
  const url = _.find(links, (link) => _.startsWith(link, 'https://'));

  if (!hasPostHeader || !url) {
    const mailto = _.find(links, (link) => _.startsWith(link, 'mailto:'));
    throw firostError(
      'GMAIL_UNSUBSCRIBE_NOT_AVAILABLE',
      mailto
        ? `No one-click unsubscribe. Send an e-mail to ${mailto.replace('mailto:', '')}`
        : 'No one-click unsubscribe in the last Message',
    );
  }

  await __.postOneClick(url);

  return { threadId, url, done: true };
}

__ = {
  /**
   * List the links of a List-Unsubscribe header
   * @param {string} value - Value of the header, links between angle brackets
   * @returns {string[]} The links, in the order of the header
   */
  parseLinks(value) {
    return _.map([...value.matchAll(/<([^>]+)>/g)], 1);
  },

  /**
   * Send the one-click POST of RFC 8058. No Google token goes to the link
   * @param {string} url - HTTPS link of the sender
   * @returns {Promise<void>} Throws GMAIL_UNSUBSCRIBE_NOT_AVAILABLE if the POST fails
   */
  async postOneClick(url) {
    let response;
    try {
      response = await __.fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'List-Unsubscribe=One-Click',
      });
    } catch (error) {
      throw firostError('GMAIL_UNSUBSCRIBE_NOT_AVAILABLE', error.message);
    }
    if (!response.ok) {
      throw firostError(
        'GMAIL_UNSUBSCRIBE_NOT_AVAILABLE',
        `The unsubscribe request failed with ${response.status}`,
      );
    }
  },

  fetch,
  getThread,
};
