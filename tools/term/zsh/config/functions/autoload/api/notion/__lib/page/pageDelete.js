import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';

export let __;

/**
 * Put one Page in the Trash. Notion can restore it
 * @param {object} options - Id of the Page
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @returns {Promise<string>} The id of the Page
 */
export async function pageDelete(options) {
  const pageId = __.parseId(options.pageId);

  await __.callApi(`pages/${pageId}`, {
    method: 'PATCH',
    body: { in_trash: true },
  });

  return pageId;
}

__ = {
  callApi,
  parseId,
};
