import { read } from 'firost';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { pageRead } from './pageRead.js';

export let __;

/**
 * Add some Content at the end of one Page. The existing Content stays
 * @param {object} options - Id of the Page, and the Content to add
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {string} [options.content] - Content to add, as markdown
 * @param {string} [options.contentFile] - Path to a markdown file. Wins over content
 * @returns {Promise<object>} The updated Page, as read
 */
export async function pageAppend(options) {
  const { content, contentFile } = options;
  const pageId = __.parseId(options.pageId);
  const markdown = contentFile ? await __.read(contentFile) : content;

  await __.callApi(`pages/${pageId}/markdown`, {
    method: 'PATCH',
    body: {
      type: 'insert_content',
      insert_content: { content: markdown },
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
