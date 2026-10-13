import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { formatIcon } from './formatIcon.js';

export let __;

/**
 * Set the Icon of one Page
 * @param {object} options - Id of the Page, and the new Icon
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {string} options.icon - An emoji, or the URL of an image
 * @returns {Promise<string>} The new Icon, as read
 */
export async function iconUpdate(options) {
  const pageId = __.parseId(options.pageId);

  const page = await __.callApi(`pages/${pageId}`, {
    method: 'PATCH',
    body: { icon: __.buildIcon(options.icon) },
  });

  return __.formatIcon(page.icon);
}

__ = {
  /**
   * Build the icon of the API from an emoji or an image URL
   * @param {string} value - An emoji, or the URL of an image
   * @returns {object} The icon, as the API expects it
   */
  buildIcon(value) {
    if (/^https?:\/\//.test(value)) {
      return { type: 'external', external: { url: value } };
    }
    return { type: 'emoji', emoji: value };
  },
  callApi,
  formatIcon,
  parseId,
};
