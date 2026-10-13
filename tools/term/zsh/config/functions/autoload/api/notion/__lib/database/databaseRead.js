import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { formatDatabase } from './formatDatabase.js';

export let __;

/**
 * Read the schema of one Database of the workspace
 * @param {object} options - Id of the Database
 * @param {string} options.databaseId - Database ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @returns {Promise<object>} The Database as { id, url, title, properties }
 */
export async function databaseRead(options) {
  const databaseId = __.parseId(options.databaseId);

  const database = await __.callApi(`databases/${databaseId}`);
  const dataSource = await __.resolveDataSource(database);

  return __.formatDatabase({ ...database, properties: dataSource.properties });
}

__ = {
  /**
   * Get the data source of a Database, which holds its properties. A Database
   * has a single one
   * @param {object} database - The Database, as returned by the API
   * @returns {Promise<object>} The data source
   */
  resolveDataSource(database) {
    return __.callApi(`data_sources/${database.data_sources[0].id}`);
  },
  callApi,
  formatDatabase,
  parseId,
};
