import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { pageSearch } from './pageSearch.js';

export let __;

/**
 * List the Pages matching a text as raw lines, one per Page. A line holds the
 * Page ID, its title, its space, then its url
 * @param {object} options - Same options as pageSearch
 * @param {string} options.query - Text to look for
 * @param {number|string} [options.limit] - Maximum number of Pages
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function pageListRaw(options) {
  const pages = await __.pageSearch(options);

  return _.chain(pages)
    .map((page) => __.toLine(page))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Page into a raw line
   * @param {object} page - Page, as returned by pageSearch
   * @returns {string} The Page ID, title, space and url, separated by ▮
   */
  toLine(page) {
    return _.chain([page.id, page.title, page.space, page.url])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  pageSearch,
};
