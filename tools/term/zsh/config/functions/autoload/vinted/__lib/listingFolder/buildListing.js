import path from 'node:path';
import { _ } from 'golgoth';
import { firostError, glob, writeJson } from 'firost';
import { listingFilePath } from './listingFilePath.js';

export let __;

const PHOTO_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
const ZERO_ISBN = '0'.repeat(13);
const DEFAULT_CATEGORY = ['Books & Media', 'Books', 'Fiction'];

/**
 * Write the listing.json of a folder of photos, from identification data
 * The file starts as a draft, with empty tracking fields.
 * @param {string} folder - Folder holding the photos
 * @param {object} identification - What identifies the book
 * @param {string} identification.series - Series or title of the book
 * @param {number|string} [identification.number] - Number in the series
 * @param {string} [identification.publisher] - Publisher
 * @param {string} [identification.isbn] - ISBN, or the zero ISBN if blank
 * @param {number} identification.price - Asking price in euros
 * @param {string[]} [identification.category] - Category labels, root to leaf
 * @returns {Promise<string>} Path of the written listing.json
 */
export async function buildListing(folder, identification) {
  const { series, number, publisher, isbn, price, category } = identification;
  const title = __.title(series, number);

  const listing = {
    photos: await __.listPhotos(folder),
    title,
    description: __.description(title, publisher),
    category: category ?? DEFAULT_CATEGORY,
    isbn: _.trim(isbn) || ZERO_ISBN,
    language: 'French',
    condition: 'Good',
    price,
    status: 'draft',
    url: null,
    postedAt: null,
    soldAt: null,
  };

  const filepath = listingFilePath(folder);
  await writeJson(listing, filepath);
  return filepath;
}

__ = {
  /**
   * List the photos of a folder, relative to it
   * @param {string} folder - Folder holding the photos
   * @returns {Promise<string[]>} Relative photo paths, sorted
   */
  async listPhotos(folder) {
    const files = await glob('**/*', { cwd: folder, directories: false });
    const photos = _.chain(files)
      .filter((file) =>
        PHOTO_EXTENSIONS.includes(path.extname(file).toLowerCase()),
      )
      .map((file) => path.relative(folder, file))
      .value();

    // A listing needs at least one photo
    if (_.isEmpty(photos)) {
      throw firostError(
        'VINTED_LISTING_NO_PHOTO',
        `No photo found in ${folder}`,
      );
    }
    return photos;
  },

  /**
   * Build the title from the series and the number
   * @param {string} series - Series or title of the book
   * @param {number|string} [number] - Number in the series
   * @returns {string} Title, like "Dune n°2"
   */
  title(series, number) {
    return _.chain([series, number && `n°${number}`])
      .compact()
      .join(' ')
      .value();
  },

  /**
   * Build the French description
   * @param {string} title - Title of the listing
   * @param {string} [publisher] - Publisher
   * @returns {string} Description
   */
  description(title, publisher) {
    return _.chain([
      `${title}.`,
      publisher && `Éditions ${publisher}.`,
      'Bon état.',
    ])
      .compact()
      .join(' ')
      .value();
  },
};
