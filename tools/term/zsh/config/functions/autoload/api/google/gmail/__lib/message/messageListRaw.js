import { _, dayjs, pMap } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { limits } from '../limits.js';
import { formatMessage } from './formatMessage.js';

export let __;

const CONCURRENCY = 10;
// The query string is part of the path, because callApi cannot repeat a
// parameter
const METADATA_QUERY =
  'format=metadata&metadataHeaders=From&metadataHeaders=Subject&metadataHeaders=Date';

/**
 * List the Messages (Gmail conversations) of the inbox as raw lines, one per
 * Message. Unread Messages come first, then the Messages by the date of their
 * last mail, newest first
 * @param {object} options - Options of the listing
 * @param {number} [options.limit] - Maximum number of Messages
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function messageListRaw(options) {
  const { limit = limits.inbox } = options;

  const response = await __.callApi('threads', {
    query: { labelIds: 'INBOX', maxResults: limit },
  });

  // The listing holds ids only, each conversation needs its own call
  const messages = await pMap(
    _.get(response, 'threads', []),
    async ({ id }) => await __.callApi(`threads/${id}?${METADATA_QUERY}`),
    { concurrency: CONCURRENCY },
  );

  return _.chain(messages)
    .map(__.formatMessage)
    .orderBy(
      [
        (message) => message.unread,
        (message) => dayjs(message.date).valueOf() || 0,
      ],
      ['desc', 'desc'],
    )
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Message into a raw line
   * @param {object} message - Message, as returned by formatMessage
   * @returns {string} The Message fields, separated by ▮
   */
  toLine(message) {
    return _.chain([
      message.id,
      message.date,
      message.count,
      message.authors,
      message.subject,
      message.snippet,
      message.unread,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },

  callApi,
  formatMessage,
};
