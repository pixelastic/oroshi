import { readFile } from 'node:fs/promises';
import { _, pMap } from 'golgoth';
import { download, hash, move, remove, run, tmpDirectory } from 'firost';
import { callApi } from '../callApi.js';
import { pageListRaw } from '../page/pageListRaw.js';
import { parseId } from '../parseId.js';
import { iconRead } from './iconRead.js';
import { iconUpdate } from './iconUpdate.js';

export let __;

const ICON_SIZE = '250';
const UPLOAD_TARGET = 'pixelastic:./local/www/assets.pixelastic.com/notion';
const PUBLIC_URL = 'https://assets.pixelastic.com/notion';
const MAX_PAGE_SIZE = 100;

/**
 * Set the Icon of a Page from the first image it holds. The image is resized,
 * named after the hash of its content, and uploaded to my server
 * @param {object} options - Id of the Page, and how far to go
 * @param {string} options.pageId - Page ID or URL. Throws NOTION_ID_INVALID if it holds no id
 * @param {boolean} [options.force] - Replace an existing Icon
 * @param {boolean} [options.recursive] - Also process the sub-pages, at every level
 * @returns {Promise<object[]>} One result per Page, with its pageId and a status: updated (with its icon), has-icon or no-image
 */
export async function iconGenerate(options) {
  const { force = false, recursive = false } = options;
  const pageId = __.parseId(options.pageId);

  const result = await __.generateOne({ pageId, force });
  if (!recursive) {
    return [result];
  }

  // Sub-pages are processed one after the other
  const subPageIds = await __.listSubPageIds(pageId);
  const subResults = await pMap(
    subPageIds,
    (subPageId) => iconGenerate({ pageId: subPageId, force, recursive }),
    { concurrency: 1 },
  );

  return [result, ..._.flatten(subResults)];
}

__ = {
  /**
   * Set the Icon of one Page, unless it has one already or holds no image
   * @param {object} options - Page and force flag
   * @param {string} options.pageId - ID of the Page
   * @param {boolean} options.force - Replace an existing Icon
   * @returns {Promise<object>} The pageId and a status: updated (with its icon), has-icon or no-image
   */
  async generateOne({ pageId, force }) {
    const currentIcon = await __.iconRead({ pageId });
    if (currentIcon && !force) {
      return { pageId, status: 'has-icon' };
    }

    const imageUrl = await __.findImageUrl(pageId);
    if (!imageUrl) {
      return { pageId, status: 'no-image' };
    }

    const iconUrl = await __.uploadImage({ pageId, imageUrl });
    const icon = await __.iconUpdate({ pageId, icon: iconUrl });
    return { pageId, status: 'updated', icon };
  },
  /**
   * Find the first image under a block, going down the nested blocks depth first
   * @param {string} blockId - ID of the Page or block to search
   * @returns {Promise<string|null>} URL of the image, or null when there is none
   */
  async findImageUrl(blockId) {
    const blocks = await __.listChildren(blockId);
    return await __.findImageUrlInBlocks(blocks);
  },
  /**
   * Find the first image in a list of blocks, and in their children
   * @param {object[]} blocks - Blocks, as returned by the API
   * @returns {Promise<string|null>} URL of the image, or null when there is none
   */
  async findImageUrlInBlocks(blocks) {
    if (_.isEmpty(blocks)) {
      return null;
    }

    const [block, ...otherBlocks] = blocks;
    if (block.type === 'image') {
      return block.image[block.image.type].url;
    }

    // Sub-pages and databases hold their own content, not the one of the page
    const isContent = !_.includes(['child_page', 'child_database'], block.type);
    const nestedUrl =
      block.has_children && isContent ? await __.findImageUrl(block.id) : null;
    return nestedUrl || (await __.findImageUrlInBlocks(otherBlocks));
  },
  /**
   * List all the children of a block, following the cursor
   * @param {string} blockId - ID of the parent block
   * @param {string} [cursor] - Cursor of the page of blocks to start from
   * @returns {Promise<object[]>} The children blocks
   */
  async listChildren(blockId, cursor) {
    const response = await __.callApi(`blocks/${blockId}/children`, {
      query: { page_size: MAX_PAGE_SIZE, start_cursor: cursor },
    });
    if (!response.has_more) {
      return response.results;
    }

    const nextBlocks = await __.listChildren(blockId, response.next_cursor);
    return [...response.results, ...nextBlocks];
  },
  /**
   * List the IDs of all the sub-pages of a Page
   * @param {string} pageId - ID of the parent Page
   * @returns {Promise<string[]>} The sub-page IDs
   */
  async listSubPageIds(pageId) {
    const rawLines = await __.pageListRaw({ pageId, limit: Infinity });
    return _.chain(rawLines)
      .split('\n')
      .compact()
      .map((line) => _.first(line.split('▮')))
      .value();
  },
  /**
   * Download an image, resize it, and upload it under the hash of its content
   * @param {object} options - Page and image
   * @param {string} options.pageId - ID of the Page, used to name the file
   * @param {string} options.imageUrl - URL of the image to download
   * @returns {Promise<string>} Public URL of the uploaded image
   */
  async uploadImage({ pageId, imageUrl }) {
    const workDirectory = __.tmpDirectory('notion');
    const filepath = `${workDirectory}/${pageId}.png`;

    try {
      await __.download(imageUrl, filepath);

      // img-resize is a zsh function, so it needs a zsh to run in
      await __.run(
        ['zsh', '-ic', 'img-resize "$@"', 'zsh', filepath, ICON_SIZE],
        { stdout: false },
      );

      const hashedFilename = `${pageId}-${await __.hashFile(filepath)}.png`;
      const hashedFilepath = `${workDirectory}/${hashedFilename}`;
      await __.move(filepath, hashedFilepath);

      await __.run(['rsync', '-az', hashedFilepath, UPLOAD_TARGET], {
        stdout: false,
      });

      return `${PUBLIC_URL}/${hashedFilename}`;
    } finally {
      await __.remove(workDirectory);
    }
  },
  /**
   * Hash the content of a file
   * @param {string} filepath - Path of the file
   * @returns {Promise<string>} Short hash of the content
   */
  async hashFile(filepath) {
    return hash(await readFile(filepath));
  },
  callApi,
  download,
  iconRead,
  iconUpdate,
  move,
  pageListRaw,
  parseId,
  remove,
  run,
  tmpDirectory,
};
