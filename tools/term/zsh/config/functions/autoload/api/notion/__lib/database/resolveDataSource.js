import { callApi } from '../callApi.js';

export let __;

/**
 * Get the data source of a Database, which holds its properties. A Database
 * has a single one
 * @param {object} database - The Database, as returned by the API
 * @returns {Promise<object>} The data source
 */
export function resolveDataSource(database) {
  return __.callApi(`data_sources/${database.data_sources[0].id}`);
}

__ = {
  callApi,
};
