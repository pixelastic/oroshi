import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatFolder } from './formatFolder.js';

export let __;

const DEFAULT_LIMIT = 25;

/**
 * List the top-level Folders of the Team as raw lines, one per Folder
 * @param {object} [options] - List options
 * @param {number} [options.limit] - Maximum number of Folders
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function folderListRaw(options = {}) {
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
    .map((folder) => __.toLine(folder))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Folder into a raw line
   * @param {object} folder - Folder, formatted
   * @returns {string} The id, name, path, parent Folder id and Scenario count, separated by ▮
   */
  toLine(folder) {
    const { id, name, path, parentId, scenariosTotal } = folder;
    return _.chain([id, name, path, parentId, scenariosTotal])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  callApi,
  getConfig,
  formatFolder,
};
