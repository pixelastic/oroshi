import { _ } from 'golgoth';
import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { pageRead } from './pageRead.js';

export let __;

/**
 * Change some Properties of one Page. The other Properties keep their value
 * @param {object} options - Id of the Page, and the Properties to change
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {string|object} [options.data] - Properties as a JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file of Properties. Wins over data
 * @returns {Promise<object>} The updated Page, as read
 */
export async function pageUpdate(options) {
  const pageId = __.parseId(options.pageId);
  const data = await __.getJsonFromOptions(options, 'data', {});

  // The Icon has its own commands, and is not a Property
  const properties = _.omit(data, 'icon');

  await __.callApi(`pages/${pageId}`, {
    method: 'PATCH',
    body: { properties },
  });

  return await __.pageRead({ pageId });
}

__ = {
  callApi,
  getJsonFromOptions,
  pageRead,
  parseId,
};
