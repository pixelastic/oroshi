import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { formatFolder } from './formatFolder.js';

export let __;

/**
 * Rename or move one Folder. The other fields keep their value
 * @param {object} options - Id of the Folder, and the fields to change
 * @param {number|string} options.folderId - Folder ID
 * @param {string} [options.name] - New name of the Folder
 * @param {number|string} [options.parentFolderId] - New parent Folder ID
 * @returns {Promise<object>} The updated Folder, formatted
 */
export async function folderUpdate(options) {
  const { folderId, name, parentFolderId } = options;

  // PATCH leaves the fields that are not given untouched
  const body = _.omitBy({ name, parentId: parentFolderId }, _.isUndefined);
  const response = await __.callApi(`scenarios-folders/${folderId}`, {
    method: 'PATCH',
    body,
  });
  return __.formatFolder(response.scenarioFolder);
}

__ = {
  callApi,
  formatFolder,
};
