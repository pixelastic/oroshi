import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';

export let __;

/**
 * Put one Database in the Trash. Notion can restore it
 * @param {object} options - Id of the Database
 * @param {string} options.databaseId - Database ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @returns {Promise<string>} The id of the Database
 */
export async function databaseDelete(options) {
  const databaseId = __.parseId(options.databaseId);

  await __.callApi(`databases/${databaseId}`, {
    method: 'PATCH',
    body: { in_trash: true },
  });

  return databaseId;
}

__ = {
  callApi,
  parseId,
};
