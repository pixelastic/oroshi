import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { formatIcon } from './formatIcon.js';

export let __;

/**
 * Read the Icon of one Page
 * @param {object} options - Id of the Page
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @returns {Promise<string>} The emoji, or the URL of the image, or an empty string when there is no Icon
 */
export async function iconRead(options) {
  const pageId = __.parseId(options.pageId);

  const page = await __.callApi(`pages/${pageId}`);

  return __.formatIcon(page.icon);
}

__ = {
  callApi,
  formatIcon,
  parseId,
};
