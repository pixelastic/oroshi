import { read } from 'firost';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { pageRead } from './pageRead.js';

export let __;

/**
 * Swap one passage of the Content of one Page for another passage
 * Notion throws if the old passage is missing, or appears several times
 * @param {object} options - Id of the Page, and the passages
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {string} [options.old] - Passage to find, as markdown
 * @param {string} [options.oldFile] - Path to a markdown file. Wins over old
 * @param {string} [options.new] - Passage to put instead, as markdown
 * @param {string} [options.newFile] - Path to a markdown file. Wins over new
 * @returns {Promise<object>} The updated Page, as read
 */
export async function pageReplace(options) {
  const { oldFile, newFile } = options;
  const pageId = __.parseId(options.pageId);
  const oldPassage = oldFile ? await __.read(oldFile) : options.old;
  const newPassage = newFile ? await __.read(newFile) : options.new;

  await __.callApi(`pages/${pageId}/markdown`, {
    method: 'PATCH',
    body: {
      type: 'update_content',
      update_content: {
        content_updates: [{ old_str: oldPassage, new_str: newPassage }],
      },
    },
  });

  return await __.pageRead({ pageId });
}

__ = {
  callApi,
  pageRead,
  parseId,
  read,
};
