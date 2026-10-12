import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatFolder } from './formatFolder.js';

export let __;

/**
 * Create one Folder in the Team
 * @param {object} options - Content of the Folder
 * @param {string} options.name - Name of the Folder
 * @param {number|string} [options.parentFolderId] - Parent Folder ID, the top level by default
 * @returns {Promise<object>} The new Folder, formatted
 */
export async function folderCreate(options) {
  const { name, parentFolderId } = options;

  const { teamId } = await __.getConfig();

  const body = _.omitBy(
    { teamId: Number(teamId), name, parentId: parentFolderId },
    _.isUndefined,
  );
  const response = await __.callApi('scenarios-folders', {
    method: 'POST',
    body,
  });
  return __.formatFolder(response.scenarioFolder);
}

__ = {
  callApi,
  formatFolder,
  getConfig,
};
