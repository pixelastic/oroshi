import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { formatDatabase } from './formatDatabase.js';

export let __;

const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;

/**
 * Search the titles of the whole workspace for Databases. It makes one API call
 * per page of results, and follows the cursor until the limit is reached or
 * the API has no more results
 * @param {object} options - Search options
 * @param {string} [options.query] - Text to look for in the titles, all Databases by default
 * @param {number} [options.limit] - Maximum number of Databases
 * @returns {Promise<object[]>} The Databases, formatted
 */
export async function databaseSearch(options) {
  const { query, limit = DEFAULT_LIMIT } = options;

  // The API searches data sources, not Databases
  const dataSources = [];
  let cursor;
  do {
    const response = await __.callApi('search', {
      method: 'POST',
      body: {
        query,
        filter: { property: 'object', value: 'data_source' },
        page_size: Math.min(limit - dataSources.length, MAX_PAGE_SIZE),
        start_cursor: cursor,
      },
    });
    dataSources.push(...response.results);
    cursor = response.has_more ? response.next_cursor : null;
  } while (cursor && dataSources.length < limit);

  // A data source has its own id, so a Database takes the id of its parent
  return _.map(dataSources, (dataSource) =>
    __.formatDatabase({ ...dataSource, id: dataSource.parent.database_id }),
  );
}

__ = {
  callApi,
  formatDatabase,
};
