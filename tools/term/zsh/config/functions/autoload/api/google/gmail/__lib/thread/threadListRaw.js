import { _, dayjs, pMap } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { limits } from '../limits.js';
import { formatThread } from './formatThread.js';

export let __;

const CONCURRENCY = 10;
// The query string is part of the path, because callApi cannot repeat a
// parameter
const METADATA_QUERY =
  'format=metadata&metadataHeaders=From&metadataHeaders=Subject&metadataHeaders=Date';

/**
 * List the Threads of the inbox as raw lines, one per Thread. Unread Threads
 * come first, then the Threads by the date of their last Message, newest first
 * @param {object} options - Options of the listing
 * @param {number} [options.limit] - Maximum number of Threads
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function threadListRaw(options) {
  const { limit = limits.inbox } = options;

  const response = await __.callApi('threads', {
    query: { labelIds: 'INBOX', maxResults: limit },
  });

  // The listing holds ids only, each Thread needs its own call
  const threads = await pMap(
    _.get(response, 'threads', []),
    async ({ id }) => await __.callApi(`threads/${id}?${METADATA_QUERY}`),
    { concurrency: CONCURRENCY },
  );

  return _.chain(threads)
    .map(formatThread)
    .orderBy(
      [
        (thread) => thread.unread,
        (thread) => dayjs(thread.date).valueOf() || 0,
      ],
      ['desc', 'desc'],
    )
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one formatted Thread into a raw line
   * @param {object} thread - Formatted Thread, as returned by formatThread
   * @returns {string} The Thread fields, separated by ▮
   */
  toLine(thread) {
    return _.chain([
      thread.threadId,
      thread.date,
      thread.count,
      thread.authors,
      thread.subject,
      thread.snippet,
      thread.unread,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },

  callApi,
};
