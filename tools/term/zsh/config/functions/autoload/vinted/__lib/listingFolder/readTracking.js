import { _ } from 'golgoth';
import { readJson } from 'firost';
import { listingFilePath } from './listingFilePath.js';

export const TRACKING_FIELDS = [
  'status',
  'url',
  'postedAt',
  'soldAt',
  'isPriceUncertain',
];

/**
 * Read the tracking fields of a listing folder
 * @param {string} folder - Listing folder
 * @returns {Promise<object>} status, url, postedAt, soldAt and isPriceUncertain
 */
export async function readTracking(folder) {
  const listing = await readJson(listingFilePath(folder));
  return _.pick(listing, TRACKING_FIELDS);
}
