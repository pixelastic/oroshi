import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';

export let __;

const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;

/**
 * List the sub-pages of a Page as raw lines, one per sub-page. A line holds the
 * sub-page ID, then its title. It makes one API call per page of blocks, and
 * follows the cursor until the limit is reached or the API has no more blocks
 * @param {object} options - List options
 * @param {string} options.pageId - ID or URL of the parent Page. Throws NOTION_ID_INVALID if it holds no id
 * @param {number} [options.limit] - Maximum number of sub-pages
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function pageListRaw(options) {
  const { limit = DEFAULT_LIMIT } = options;
  const pageId = __.parseId(options.pageId);

  // Sub-pages are the child_page blocks among the blocks of the parent
  const subPages = [];
  let cursor;
  do {
    const response = await __.callApi(`blocks/${pageId}/children`, {
      query: {
        page_size: Math.min(limit - subPages.length, MAX_PAGE_SIZE),
        start_cursor: cursor,
      },
    });
    subPages.push(..._.filter(response.results, { type: 'child_page' }));
    cursor = response.has_more ? response.next_cursor : null;
  } while (cursor && subPages.length < limit);

  return _.chain(subPages)
    .map((subPage) => __.toLine(subPage))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one child_page block into a raw line
   * @param {object} block - The child_page block, as returned by the API
   * @returns {string} The sub-page ID and its title, separated by ▮
   */
  toLine(block) {
    return _.chain([block.id, block.child_page.title])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  callApi,
  parseId,
};
