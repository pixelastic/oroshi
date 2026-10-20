import { _ } from 'golgoth';
import { firostError, readJson, writeJson } from 'firost';
import { listingFilePath } from './listingFilePath.js';
import { TRACKING_FIELDS } from './readTracking.js';

const STATUSES = ['draft', 'online', 'sold'];

/**
 * Update the tracking fields of a listing folder, and nothing else
 * @param {string} folder - Listing folder
 * @param {object} changes - New values. Keys other than tracking fields are ignored
 * @returns {Promise<object>} The tracking fields after the update
 */
export async function updateTracking(folder, changes) {
  const tracking = _.pick(changes, TRACKING_FIELDS);

  // An unknown status would break every reader of the folder
  if (tracking.status !== undefined && !STATUSES.includes(tracking.status)) {
    throw firostError(
      'VINTED_LISTING_STATUS_INVALID',
      `status must be one of ${STATUSES.join(', ')}`,
    );
  }

  const filepath = listingFilePath(folder);
  const listing = { ...(await readJson(filepath)), ...tracking };
  await writeJson(listing, filepath);
  return _.pick(listing, TRACKING_FIELDS);
}
