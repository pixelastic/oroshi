import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
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
 * Search the Threads with a native Gmail query
 * @param {object} options - Search options
 * @param {string} options.query - Gmail query (from:bob is:unread). Throws GMAIL_QUERY_MISSING if empty
 * @param {number} [options.limit] - Maximum number of Threads
 * @returns {Promise<object[]>} The Thread envelopes, in the order Gmail returns them. Their Messages carry metadata only
 */
export async function threadSearch(options) {
  const { query, limit = limits.search } = options;

  // An empty query would list the whole account
  if (!query) {
    throw firostError('GMAIL_QUERY_MISSING', 'Pass a Gmail query');
  }

  const response = await __.callApi('threads', {
    query: { q: query, maxResults: limit },
  });

  // The listing holds ids only, each Thread needs its own call
  const threads = await pMap(
    _.get(response, 'threads', []),
    async ({ id }) => await __.callApi(`threads/${id}?${METADATA_QUERY}`),
    { concurrency: CONCURRENCY },
  );

  return _.map(threads, __.toEnvelope);
}

__ = {
  /**
   * Format one Thread as an envelope. The metadata format gives no recipient,
   * body or attachment, so the Messages keep only the keys it provides
   * @param {object} response - The Thread, as returned by the Gmail API with the metadata format
   * @returns {object} The Thread as { threadId, subject, unread, messages }
   */
  toEnvelope(response) {
    const { threadId, subject, unread, messages } = formatThread(response, {
      format: 'metadata',
    });
    return { threadId, subject, unread, messages };
  },

  callApi,
};
