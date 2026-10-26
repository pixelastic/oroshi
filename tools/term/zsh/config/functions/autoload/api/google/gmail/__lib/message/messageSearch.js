import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
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
 * Search the Messages (Gmail conversations) with a native Gmail query
 * @param {object} options - Search options
 * @param {string} options.query - Gmail query (from:bob is:unread). Throws GMAIL_QUERY_MISSING if empty
 * @param {number} [options.limit] - Maximum number of Messages
 * @returns {Promise<object[]>} The Messages, formatted, in the order Gmail returns them
 */
export async function messageSearch(options) {
  const { query, limit = limits.search } = options;

  // An empty query would list the whole mailbox
  if (!query) {
    throw firostError('GMAIL_QUERY_MISSING', 'Pass a Gmail query');
  }

  const response = await __.callApi('threads', {
    query: { q: query, maxResults: limit },
  });

  // The listing holds ids only, each conversation needs its own call
  const messages = await pMap(
    _.get(response, 'threads', []),
    async ({ id }) => await __.callApi(`threads/${id}?${METADATA_QUERY}`),
    { concurrency: CONCURRENCY },
  );

  return _.map(messages, __.formatMessage);
}

__ = {
  callApi,
  formatMessage,
};
