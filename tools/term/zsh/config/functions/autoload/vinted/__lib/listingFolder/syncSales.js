import { _, pMap } from 'golgoth';
import { readListingFolders } from './readListingFolders.js';
import { updateTracking } from './updateTracking.js';

const ITEM_ID_PATTERN = /\/items\/(\d+)/;

/**
 * Mark the listings that were sold on Vinted
 * A listing matches when the id in its url is a sold id. The title is never
 * used. A listing already sold keeps its soldAt.
 * @param {string} root - Folder holding one folder per listing
 * @param {string[]} soldIds - Item ids found on the sales page
 * @param {object} [options] - Options
 * @param {Date} [options.now] - Sale date to record
 * @returns {Promise<string[]>} Folders marked as sold
 */
export async function syncSales(root, soldIds, { now = new Date() } = {}) {
  const entries = await readListingFolders(root);
  const sold = _.chain(entries)
    .filter(({ listing }) => listing.status !== 'sold')
    .filter(({ listing }) =>
      _.includes(soldIds, _.get(ITEM_ID_PATTERN.exec(listing.url), 1)),
    )
    .map('folder')
    .value();

  await pMap(sold, (folder) =>
    updateTracking(folder, { status: 'sold', soldAt: now.toISOString() }),
  );
  return sold;
}
