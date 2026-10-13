import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { formatPage } from './formatPage.js';

export let __;

/**
 * Read one Page of the workspace
 * @param {object} options - Id of the Page
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @returns {Promise<object>} The Page as { id, url, properties, markdown }
 */
export async function pageRead(options) {
  const pageId = __.parseId(options.pageId);

  // The markdown has its own endpoint
  const [page, content] = await Promise.all([
    __.callApi(`pages/${pageId}`),
    __.callApi(`pages/${pageId}/markdown`),
  ]);

  return { ...__.formatPage(page), markdown: content.markdown };
}

__ = {
  callApi,
  formatPage,
  parseId,
};
