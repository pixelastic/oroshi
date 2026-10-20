import path from 'node:path';
import { _, pMap } from 'golgoth';
import { firostError, glob, readJson, run, sleep } from 'firost';
import { listingFilePath } from './listingFilePath.js';
import { parsePostedUrl } from './parsePostedUrl.js';
import { updateTracking } from './updateTracking.js';

export let __;

const MISC_FOLDER = 'Misc';
const POST_BIN = path.resolve(
  import.meta.dirname,
  '../bin/vinted-listing-create.js',
);

/**
 * Publish the draft listings under a root, one at a time
 * Each publication is recorded in its listing file. A listing with a url is
 * skipped, so a re-run never creates a duplicate. The first failure stops the
 * batch.
 * @param {string} root - Folder holding one folder per listing
 * @param {object} [options] - Options
 * @param {number} [options.pauseInMs] - Pause between two listings
 * @returns {Promise<object[]>} The folder and url of each published listing
 */
export async function publishListings(root, { pauseInMs = 5000 } = {}) {
  const folders = await __.readPendingFolders(root);

  // One at a time: two parallel posts could create duplicates
  return await pMap(
    folders,
    async (folder, index) => {
      if (index > 0) {
        await __.sleep(pauseInMs);
      }
      const url = await __.publishFolder(folder);
      return { folder, url };
    },
    { concurrency: 1 },
  );
}

__ = {
  /**
   * List the folders of the draft listings that have no url, outside Misc
   * @param {string} root - Folder holding one folder per listing
   * @returns {Promise<string[]>} Absolute folder paths, sorted
   */
  async readPendingFolders(root) {
    const absoluteRoot = path.resolve(root);
    const files = await glob('**/listing.json', { cwd: absoluteRoot });
    const kept = _.chain(files)
      .map((file) => path.resolve(absoluteRoot, file))
      .reject((file) =>
        _.startsWith(
          path.relative(absoluteRoot, file),
          `${MISC_FOLDER}${path.sep}`,
        ),
      )
      .sortBy()
      .value();

    const listings = await Promise.all(kept.map((file) => readJson(file)));
    return _.chain(kept)
      .zip(listings)
      .filter(([, { status, url }]) => status === 'draft' && !url)
      .map(([file]) => path.dirname(file))
      .value();
  },

  /**
   * Post a listing folder and record the publication
   * @param {string} folder - Absolute path of the listing folder
   * @returns {Promise<string>} URL of the published listing
   */
  async publishFolder(folder) {
    try {
      const output = await __.postListing(listingFilePath(folder));
      const url = parsePostedUrl(output);
      await updateTracking(folder, {
        url,
        postedAt: new Date().toISOString(),
        status: 'online',
      });
      return url;
    } catch (error) {
      throw firostError(
        'VINTED_LISTING_PUBLISH_FAILED',
        `Publication stopped at ${folder}: ${error.message}`,
      );
    }
  },

  /**
   * Run the post helper on a listing file
   * @param {string} listingPath - Absolute path of listing.json
   * @returns {Promise<string>} Output of the helper
   */
  async postListing(listingPath) {
    const { stdout } = await run(['node', POST_BIN, listingPath]);
    return stdout;
  },

  sleep,
};
