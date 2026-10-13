import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { formatPage } from './formatPage.js';

export let __;

const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;

/**
 * Search the titles of the whole workspace for Pages. It makes one API call
 * per page of results, and follows the cursor until the limit is reached or
 * the API has no more results
 * @param {object} options - Search options
 * @param {string} [options.query] - Text to look for in the titles, all Pages by default
 * @param {number} [options.limit] - Maximum number of Pages
 * @returns {Promise<object[]>} The Pages, formatted
 */
export async function pageSearch(options) {
  const { query, limit = DEFAULT_LIMIT } = options;

  const pages = [];
  let cursor;
  do {
    const response = await __.callApi('search', {
      method: 'POST',
      body: {
        query,
        filter: { property: 'object', value: 'page' },
        page_size: Math.min(limit - pages.length, MAX_PAGE_SIZE),
        start_cursor: cursor,
      },
    });
    pages.push(...response.results);
    cursor = response.has_more ? response.next_cursor : null;
  } while (cursor && pages.length < limit);

  return _.map(pages, __.formatPage);
}

__ = {
  callApi,
  formatPage,
};
