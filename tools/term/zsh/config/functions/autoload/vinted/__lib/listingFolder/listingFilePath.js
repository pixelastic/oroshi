import path from 'node:path';

const LISTING_FILE = 'listing.json';

/**
 * Get the path of the listing file of a folder
 * @param {string} folder - Listing folder
 * @returns {string} Path of listing.json in the folder
 */
export function listingFilePath(folder) {
  return path.join(folder, LISTING_FILE);
}
