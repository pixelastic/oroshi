import { firostError } from 'firost';
import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { buildTitle } from './buildTitle.js';
import { databaseRead } from './databaseRead.js';

export let __;

/**
 * Create one Database under a Parent Page
 * @param {object} options - Parent and schema of the Database
 * @param {string} options.parentPageId - ID or URL of the parent Page. Throws NOTION_PARENT_MISSING if absent, NOTION_ID_INVALID if it holds no id
 * @param {string|object} [options.data] - Schema as a JSON string, or the object itself: { title, properties }
 * @param {string} [options.dataFile] - Path to a JSON file of the schema. Wins over data
 * @returns {Promise<object>} The new Database, as read
 */
export async function databaseCreate(options) {
  // There is no creation at the root of the workspace
  if (!options.parentPageId) {
    throw firostError('NOTION_PARENT_MISSING', 'Pass --parentPageId');
  }

  const parentPageId = __.parseId(options.parentPageId);
  const { title, properties } = await __.getJsonFromOptions(
    options,
    'data',
    {},
  );

  const response = await __.callApi('databases', {
    method: 'POST',
    body: {
      parent: { type: 'page_id', page_id: parentPageId },
      title: buildTitle(title),
      initial_data_source: { properties },
    },
  });

  return await __.databaseRead({ databaseId: response.id });
}

__ = {
  callApi,
  databaseRead,
  getJsonFromOptions,
  parseId,
};
