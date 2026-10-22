import { _, dayjs } from 'golgoth';
import { readListingFolders } from './readListingFolders.js';

/**
 * List the listings online for more than a number of days
 * @param {string} root - Folder holding one folder per listing
 * @param {object} options - Options
 * @param {number} options.days - Age threshold, in days
 * @param {Date} [options.now] - Date to measure the age from
 * @returns {Promise<object[]>} Each listing as { folder, title, url, ageInDays }
 */
export async function listStaleListings(root, { days, now = new Date() }) {
  const entries = await readListingFolders(root);

  return _.chain(entries)
    .filter(({ listing }) => listing.status === 'online' && listing.postedAt)
    .map(({ folder, listing }) => ({
      folder,
      title: listing.title,
      url: listing.url,
      age: dayjs(now).diff(listing.postedAt, 'day', true),
    }))
    .filter(({ age }) => age > days)
    .map(({ age, ...rest }) => ({ ...rest, ageInDays: Math.floor(age) }))
    .value();
}
