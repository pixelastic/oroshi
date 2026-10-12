import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { folderRead } from './folderRead.js';

export let __;

/**
 * Delete one empty Folder of the Team
 * @param {object} options - Id of the Folder
 * @param {number|string} options.folderId - Folder ID
 * @returns {Promise<number|string>} The ID of the removed Folder
 */
export async function folderDelete(options) {
  const { folderId } = options;

  // The API deletes the subfolders and moves the Scenarios to the parent
  // Folder, so a Folder with content is refused
  const folder = await __.folderRead({ folderId });
  if (!_.isEmpty(folder.subfolders) || !_.isEmpty(folder.scenarios)) {
    throw firostError(
      'MAKE_FOLDER_NOT_EMPTY',
      `Folder ${folderId} holds subfolders or Scenarios`,
    );
  }

  await __.callApi(`scenarios-folders/${folderId}`, { method: 'DELETE' });
  return folderId;
}

__ = {
  callApi,
  folderRead,
};
