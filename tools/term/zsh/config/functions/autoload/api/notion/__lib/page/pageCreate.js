import { firostError, read } from 'firost';
import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { pageRead } from './pageRead.js';

export let __;

/**
 * Create one Page under a Parent. The Content is sent in the same call
 * @param {object} options - Parent and content of the Page
 * @param {string} [options.parentPageId] - ID or URL of the parent Page. Throws NOTION_ID_INVALID if it holds no id. Exclusive with parentDatabaseId
 * @param {string} [options.parentDatabaseId] - ID or URL of the parent Database. Exclusive with parentPageId. Throws NOTION_PARENT_MISSING if no parent or both are passed
 * @param {string|object} [options.data] - Properties as a JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file of Properties. Wins over data
 * @param {string} [options.content] - Content of the Page, as markdown
 * @param {string} [options.contentFile] - Path to a markdown file. Wins over content
 * @returns {Promise<object>} The new Page, as read
 */
export async function pageCreate(options) {
  const { parentPageId, parentDatabaseId, content, contentFile } = options;

  // Exactly one Parent is needed
  if (!parentPageId === !parentDatabaseId) {
    throw firostError(
      'NOTION_PARENT_MISSING',
      'Pass exactly one of --parentPageId and --parentDatabaseId',
    );
  }

  const parent = await __.getParent({ parentPageId, parentDatabaseId });
  const properties = await __.getJsonFromOptions(options, 'data', {});
  const markdown = contentFile ? await __.read(contentFile) : content;

  const response = await __.callApi('pages', {
    method: 'POST',
    body: { parent, properties, markdown },
  });

  return await __.pageRead({ pageId: response.id });
}

__ = {
  /**
   * Build the parent of the API call. A Database has a single data source,
   * and the rows live in it
   * @param {object} options - The one Parent that was passed
   * @param {string} [options.parentPageId] - ID or URL of the parent Page
   * @param {string} [options.parentDatabaseId] - ID or URL of the parent Database
   * @returns {Promise<object>} The parent, as the API expects it
   */
  async getParent(options) {
    if (options.parentPageId) {
      return { type: 'page_id', page_id: __.parseId(options.parentPageId) };
    }

    const databaseId = __.parseId(options.parentDatabaseId);
    const database = await __.callApi(`databases/${databaseId}`);
    return {
      type: 'data_source_id',
      data_source_id: database.data_sources[0].id,
    };
  },
  callApi,
  getJsonFromOptions,
  pageRead,
  parseId,
  read,
};
