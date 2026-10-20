import path from 'node:path';
import { _ } from 'golgoth';
import { glob, readJson } from 'firost';

export let __;

const MISC_FOLDER = 'Misc';

/**
 * Summarize the draft listings under a root
 * Listings in the Misc folder are not ready to publish, so they are skipped.
 * @param {string} root - Folder holding one folder per listing
 * @returns {Promise<object>} count, total asked price and uncertain prices
 */
export async function recapListings(root) {
  const drafts = await __.readDrafts(root);

  return {
    count: drafts.length,
    total: _.sumBy(drafts, 'price'),
    uncertain: _.chain(drafts)
      .filter('isPriceUncertain')
      .map(({ title, price }) => ({ title, price }))
      .value(),
  };
}

__ = {
  /**
   * Read the draft listings of a root, outside the Misc folder
   * @param {string} root - Folder holding one folder per listing
   * @returns {Promise<object[]>} The listings with a draft status
   */
  async readDrafts(root) {
    const files = await glob('**/listing.json', { cwd: root });
    const kept = _.reject(files, (file) =>
      _.startsWith(path.relative(root, file), `${MISC_FOLDER}${path.sep}`),
    );
    const listings = await Promise.all(kept.map((file) => readJson(file)));
    return _.filter(listings, { status: 'draft' });
  },
};
