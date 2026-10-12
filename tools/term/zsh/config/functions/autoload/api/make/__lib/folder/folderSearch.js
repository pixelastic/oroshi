import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatFolder } from './formatFolder.js';

export let __;

const DEFAULT_LIMIT = 25;

/**
 * Search the top-level Folders of the Team
 * @param {object} [options] - Search options
 * @param {number} [options.limit] - Maximum number of Folders
 * @returns {Promise<object[]>} The Folders, formatted
 */
export async function folderSearch(options = {}) {
  const { limit = DEFAULT_LIMIT } = options;

  const { teamId } = await __.getConfig();
  const response = await __.callApi('scenarios-folders', {
    query: {
      teamId,
      'pg[limit]': limit,
    },
  });

  // The API ignores pg[limit] on Folders, so the limit is applied here
  return _.chain(response.scenariosFolders)
    .take(limit)
    .map((folder) => __.formatFolder(folder))
    .value();
}

__ = {
  callApi,
  getConfig,
  formatFolder,
};
