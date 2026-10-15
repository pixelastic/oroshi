import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { scenarioSearch } from '../scenario/scenarioSearch.js';
import { formatFolder } from './formatFolder.js';

export let __;

/**
 * Read one Folder of the Team, with its direct subfolders and direct Scenarios
 * @param {object} options - Id of the Folder
 * @param {number|string} options.folderId - Folder ID
 * @returns {Promise<object>} The Folder, with its subfolders and scenarios
 */
export async function folderRead(options) {
  const folderId = Number(options.folderId);

  const { teamId } = await __.getConfig();
  const folder = await __.findFolder(folderId, teamId);
  if (!folder) {
    throw firostError('MAKE_FOLDER_NOT_FOUND', `No Folder ${folderId}`);
  }

  // A found Folder may come from the nested children of a listing, so its
  // subfolders are always listed on their own
  const subfolders = await __.listFolders(teamId, folderId);
  const scenarios = await __.scenarioSearch({
    folderId,
    limit: Infinity,
  });

  return {
    ...__.formatFolder(_.omit(folder, 'children')),
    subfolders: _.map(subfolders, (subfolder) =>
      __.formatFolder(_.omit(subfolder, 'children')),
    ),
    scenarios,
  };
}

__ = {
  /**
   * List the Folders directly under a parent Folder
   * @param {string} teamId - Team ID
   * @param {number} [parentId] - Parent Folder ID, the top level by default
   * @returns {Promise<object[]>} The Folders, as returned by the API
   */
  async listFolders(teamId, parentId) {
    const response = await __.callApi('scenarios-folders', {
      query: { teamId, parentId },
    });
    return response.scenariosFolders;
  },
  /**
   * Find a Folder by its id, at any depth. The API has no endpoint to read
   * one Folder, and lists only the children of one parent at a time
   * @param {number} folderId - Folder ID
   * @param {string} teamId - Team ID
   * @param {number} [parentId] - Parent Folder ID to look under, the top level by default
   * @returns {Promise<object|undefined>} The Folder, or undefined if not found
   */
  async findFolder(folderId, teamId, parentId) {
    const folders = await __.listFolders(teamId, parentId);

    // A listing nests the direct subfolders of every Folder it returns
    const subfolders = _.flatMap(folders, 'children');
    const found = _.find([...folders, ...subfolders], { id: folderId });
    if (found) {
      return found;
    }

    // Go deeper only under the subfolders that have subfolders themselves
    const parents = _.filter(subfolders, 'hasChildren');
    const results = await pMap(parents, (parent) =>
      __.findFolder(folderId, teamId, parent.id),
    );
    return _.find(results);
  },
  callApi,
  getConfig,
  formatFolder,
  scenarioSearch,
};
