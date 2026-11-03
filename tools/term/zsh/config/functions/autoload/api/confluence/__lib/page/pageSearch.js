import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatPage } from './formatPage.js';

export let __;

const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;
const HIGHLIGHT_MARKERS = /@@@(end)?hl@@@/g;

/**
 * Search the Pages of Confluence by text. It makes one API call per page, and
 * moves the start forward until it has the limit, or the API has no more results
 * @param {object} options - Search options
 * @param {string} options.query - Text to look for. Throws CONFLUENCE_QUERY_MISSING if empty
 * @param {number|string} [options.limit] - Maximum number of Pages
 * @returns {Promise<object[]>} The Pages as { id, title, space, url, excerpt }
 */
export async function pageSearch(options) {
  const { query, limit = DEFAULT_LIMIT } = options;

  if (!query) {
    throw firostError('CONFLUENCE_QUERY_MISSING', 'Pass the text to search');
  }

  const { domain } = await __.getConfig();
  // The search is only served by the v1 API
  const cql = `type = page AND text ~ "${__.escapeCql(query)}"`;

  // A flag gives the limit as a string
  const wanted = Number(limit);
  const results = [];
  let hasNext = true;
  while (hasNext && results.length < wanted) {
    const response = await __.callApi('search', {
      apiPath: 'wiki/rest/api',
      query: {
        cql,
        limit: Math.min(wanted - results.length, MAX_PAGE_SIZE),
        start: results.length,
      },
    });
    results.push(...response.results);
    hasNext = Boolean(response._links?.next) && !_.isEmpty(response.results);
  }

  return _.chain(results)
    .take(wanted)
    .map((result) => __.formatPage(result))
    .map((page) => ({
      id: page.content.id,
      title: page.title,
      space: page.resultGlobalContainer.title,
      // The API gives a path, the domain comes from the config
      url: `https://${domain}/wiki${page.url}`,
      excerpt: page.excerpt.replace(HIGHLIGHT_MARKERS, ''),
    }))
    .value();
}

__ = {
  /**
   * Escape a text, to put it between double quotes in a CQL query
   * @param {string} text - The text to escape
   * @returns {string} The text, with its backslashes and quotes escaped
   */
  escapeCql(text) {
    return text.replace(/[\\"]/g, '\\$&');
  },
  callApi,
  formatPage,
  getConfig,
};
