import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { buildTitle } from './buildTitle.js';
import { databaseRead } from './databaseRead.js';
import { resolveDataSource } from './resolveDataSource.js';

export let __;

/**
 * Change the title and the Properties of one Database. What is not given stays as is
 * @param {object} options - Id of the Database, and the changes
 * @param {string} options.databaseId - Database ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {string|object} [options.data] - Changes as a JSON string, or the object itself: { title, properties }
 * @param {string} [options.dataFile] - Path to a JSON file of changes. Wins over data
 * @returns {Promise<object>} The updated Database, as read
 */
export async function databaseUpdate(options) {
  const databaseId = __.parseId(options.databaseId);
  const { title, properties } = await __.getJsonFromOptions(
    options,
    'data',
    {},
  );

  // The title lives on the Database, and the Properties on its data source
  if (title) {
    await __.callApi(`databases/${databaseId}`, {
      method: 'PATCH',
      body: { title: buildTitle(title) },
    });
  }
  if (properties) {
    const database = await __.callApi(`databases/${databaseId}`);
    const dataSource = await __.resolveDataSource(database);
    await __.callApi(`data_sources/${dataSource.id}`, {
      method: 'PATCH',
      body: { properties },
    });
  }

  return await __.databaseRead({ databaseId });
}

__ = {
  callApi,
  databaseRead,
  getJsonFromOptions,
  parseId,
  resolveDataSource,
};
