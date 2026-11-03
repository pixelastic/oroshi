import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatPage } from './formatPage.js';
import { parsePageId } from './parsePageId.js';

export let __;

/**
 * Read one Page of Confluence
 * @param {object} options - Id of the Page
 * @param {string} options.pageId - Page ID or URL. Throws CONFLUENCE_ID_INVALID if it holds no id
 * @returns {Promise<object>} The Page as { id, title, spaceId, url, markdown }
 */
export async function pageRead(options) {
  const pageId = __.parsePageId(options.pageId);

  const response = await __.callApi(`pages/${pageId}`, {
    query: { 'body-format': 'storage' },
  });
  const { id, title, spaceId, _links, body } = __.formatPage(response);

  // The API gives a path, the domain comes from the config
  const { domain } = await __.getConfig();
  const url = `https://${domain}/wiki${_links.webui}`;

  // The markdown key holds the raw storage HTML until it is converted
  return { id, title, spaceId, url, markdown: body.storage.value };
}

__ = {
  callApi,
  formatPage,
  getConfig,
  parsePageId,
};
