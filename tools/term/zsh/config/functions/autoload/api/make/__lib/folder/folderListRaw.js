import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { folderSearch } from './folderSearch.js';

export let __;

/**
 * List the Folders of the Team as raw lines, one per Folder
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function folderListRaw(options) {
  // Ask search for the Folders, with the flags we received
  const folders = await __.folderSearch(options);

  return _.chain(folders)
    .map((folder) => __.toLine(folder))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Folder into a raw line
   * @param {object} folder - Folder, as returned by search
   * @returns {string} The id, name, path, parent Folder id and Scenario count, separated by ▮
   */
  toLine(folder) {
    const { id, name, path, parentId, scenariosTotal } = folder;
    return _.chain([id, name, path, parentId, scenariosTotal])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  folderSearch,
};
