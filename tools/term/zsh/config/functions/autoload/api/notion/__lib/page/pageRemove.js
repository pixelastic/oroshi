import { pageReplace } from './pageReplace.js';

export let __;

/**
 * Delete one passage of the Content of one Page
 * @param {object} options - Id of the Page, and the passage
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {string} [options.old] - Passage to delete, as markdown
 * @param {string} [options.oldFile] - Path to a markdown file. Wins over old
 * @returns {Promise<object>} The updated Page, as read
 */
export async function pageRemove(options) {
  const { pageId, old, oldFile } = options;

  return await __.pageReplace({ pageId, old, oldFile, new: '' });
}

__ = {
  pageReplace,
};
